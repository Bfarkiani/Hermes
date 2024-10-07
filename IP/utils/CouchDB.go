package utils

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"github.com/go-kivik/kivik/v4"
	_ "github.com/go-kivik/kivik/v4/couchdb"
	"github.com/go-kivik/kivik/v4/couchdb/chttp"
	"github.com/icza/dyno"
	"log"
	"sigs.k8s.io/yaml"
)

type CouchDB struct {
	client *kivik.Client
}

func NewConnectionCouchDB(dbUserName, dbPassword, dbIP, dbPort string) (CouchDB, error) {
	url := fmt.Sprintf("http://%s:%s@%s:%s/", dbUserName, dbPassword, dbIP, dbPort)
	client, err := kivik.New("couch", url)
	if err != nil {
		log.Fatal("error connecting to the DB", err.(*chttp.HTTPError).Reason)

	}

	return CouchDB{
		client: client,
	}, nil

}

func (con *CouchDB) UpdateDB(dbName string, inputYaml []byte, docID string) error {
	//first read database and if document already exist copy its version. if not just push it

	db := con.client.DB(dbName)
	rev, err := db.GetRev(context.TODO(), docID)
	if err != nil {
		if err.(*chttp.HTTPError).HTTPStatus() == 404 {
			log.Println(fmt.Sprintf("Document ID: %s does not exist so this is the first push ", docID))
			rev = ""
		} else {
			log.Fatal(fmt.Sprintf("error fetching revision of ID: %s \n %s", docID, err.(*chttp.HTTPError).Reason))
		}
	}

	//convert yaml to json
	var body interface{}
	if errr := yaml.Unmarshal(inputYaml, &body); errr != nil {
		log.Fatal("Failed unmarshaling ")
	}
	DBout, err := json.Marshal(dyno.ConvertMapI2MapS(body))
	if err != nil {
		log.Fatal("Failed converting to json ")
	}

	var DBout_raw map[string]interface{}

	configDecoder := json.NewDecoder(bytes.NewReader(DBout))
	err = configDecoder.Decode(&DBout_raw)
	if err != nil {
		log.Println(fmt.Sprintf("Error decoding JSON for ID: %s \n %s ", docID, err))
		return err
	}

	if rev != "" {
		DBout_raw["_rev"] = rev //current id we received from previous update
	}

	rev, err = db.Put(context.TODO(), docID, DBout_raw)
	if err != nil {
		log.Println(fmt.Sprintf("Failed updating ID: %s ", docID))
		return err
	}
	fmt.Printf("Doc %s inserted with revision %s\n", docID, rev)
	return nil
}

func (conn *CouchDB) Clean() error {
	if conn.client != nil {
		conn.client.Close()
	}
	return nil
}

func (con *CouchDB) InitializeDB(dbname string) error {
	exist, _ := con.client.DBExists(context.Background(), dbname)
	if exist {
		//drop db
		err := con.client.DestroyDB(context.Background(), dbname)
		if err != nil {
			log.Fatal(fmt.Sprintf("Failed to delete DB %s", dbname))
		}
		log.Println(fmt.Sprintf("DB %s existerd and I deleted it", dbname))
	}
	err := con.client.CreateDB(context.Background(), dbname)
	if err != nil {
		log.Fatal(fmt.Sprintf("Failed to create DB %s, error: \n", dbname, err))
	}
	log.Println(fmt.Sprintf("Successfully created DB %s", dbname))
	return err

}

func (con *CouchDB) ConnectDB(dbname string) *kivik.DB {
	exist, _ := con.client.DBExists(context.Background(), dbname)
	if !exist {
		log.Println(fmt.Sprintf("DB %s does not exist", dbname))
		return nil
	}
	db := con.client.DB(dbname)
	return db
}

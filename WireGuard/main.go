package main

import (
	"WireGuard/utils"
	"bytes"
	"flag"
	"fmt"
	"github.com/prometheus-community/pro-bing"
	"io"
	"io/fs"
	"log"
	"os"
	"os/signal"
	"path/filepath"
	"strings"
	"sync"
	"time"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func main() {
	var wg sync.WaitGroup

	dbAddress := flag.String("dbaddress", "192.168.1.1", "CouchDB address")
	dbPort := flag.String("dbport", "5984", "CouchDB port")
	pingAddress := flag.String("pingaddress", "10.0.0.1", "address to ping")
	pinger := flag.Bool("pinger", false, "is this a databse updater instance?")
	flag.Parse()
	fmt.Println(fmt.Sprintf("Running DB Updater with following uptions: \n dbAddress: %s, dbPort: %s, pingAddress: %s", *dbAddress, *dbPort, *pingAddress))
	if *pinger {
		p, err := probing.NewPinger(*pingAddress)

		if err != nil {
			panic(err)
		}

		c := make(chan os.Signal, 1)
		signal.Notify(c, os.Interrupt)
		p.SetPrivileged(true)
		wg.Add(1)
		go func() {
			//defer wg.Done()
			for _ = range c {
				p.Stop()
			}
		}()
		outputBuffer := bytes.Buffer{}

		p.OnRecv = func(pkt *probing.Packet) {
			fmt.Printf("%d bytes from %s: icmp_seq=%d time=%v\n",
				pkt.Nbytes, pkt.IPAddr, pkt.Seq, pkt.Rtt)
			outputBuffer.WriteString(fmt.Sprintf("icmp_seq=%d time=%v\n", pkt.Seq, pkt.Rtt))
		}

		p.OnDuplicateRecv = func(pkt *probing.Packet) {
			fmt.Printf("%d bytes from %s: icmp_seq=%d time=%v ttl=%v (DUP!)\n",
				pkt.Nbytes, pkt.IPAddr, pkt.Seq, pkt.Rtt, pkt.TTL)
		}

		p.OnFinish = func(stats *probing.Statistics) {
			defer wg.Done()
			fmt.Printf("\n--- %s ping statistics ---\n", stats.Addr)
			fmt.Printf("%d packets transmitted, %d packets received, %v%% packet loss\n",
				stats.PacketsSent, stats.PacketsRecv, stats.PacketLoss)
			fmt.Printf("round-trip min/avg/max/stddev = %v/%v/%v/%v\n",
				stats.MinRtt, stats.AvgRtt, stats.MaxRtt, stats.StdDevRtt)
			f, err := os.CreateTemp("", "ping.txt")
			check(err)
			fmt.Printf("writing ping to %s\n", f.Name())
			f.Write(outputBuffer.Bytes())
			f.Sync()
			f.Close()

		}

		fmt.Printf("PING %s (%s):\n", p.Addr(), p.IPAddr())
		wg.Add(1)
		go func() {
			defer wg.Done()
			err := p.Run()
			if err != nil {
				check(err)
			}
		}()
		fmt.Println("Hit CTRL-C to stop")
	}

	couchDB, err := utils.NewConnectionCouchDB("ONL", "123456", *dbAddress, *dbPort)
	if err != nil {
		log.Fatal("Failed to connect to CouchDB")
	}


	var dbFunction func(string, fs.DirEntry, error) error
	dbFunction = func(path string, d fs.DirEntry, err error) error {
		var errx error
		if d.IsDir() == false {
			//process file
			configName := strings.Split(d.Name(), ".")[0]
			DBFile := path
			input, err := os.OpenFile(DBFile, os.O_RDONLY, os.ModePerm)
			if err != nil {
				log.Fatal("Failed reading ", DBFile)
			}
			outYaml, _ := io.ReadAll(input)

			couchDB.UpdateDB("users", outYaml, configName)

		}
		return errx
	}

	basePATH, err := os.Getwd()
	if err != nil {
		log.Fatal("Failed getting directory list ", err)
		panic(err)
	}
	fmt.Println("sleeping for a minute...")
	time.Sleep(60 * time.Second)
	currentTime := time.Now()
	fmt.Printf("start at: %02d:%02d:%02d\n", currentTime.Hour(), currentTime.Minute(), currentTime.Second())
	configPath := filepath.Join(basePATH, "update1")
	f := fs.WalkDirFunc(dbFunction)

	filepath.WalkDir(configPath, f)
	fmt.Printf("Done at: %02d:%02d:%02d\n", currentTime.Hour(), currentTime.Minute(), currentTime.Second())

	///now update again

	fmt.Println("sleeping for 3 minutes")
	time.Sleep(180 * time.Second)

	configPath = filepath.Join(basePATH, "update2")
	currentTime = time.Now()
	fmt.Printf("start at: %02d:%02d:%02d\n", currentTime.Hour(), currentTime.Minute(), currentTime.Second())
	filepath.WalkDir(configPath, f)
	fmt.Printf("Done at: %02d:%02d:%02d\n", currentTime.Hour(), currentTime.Minute(), currentTime.Second())

	fmt.Println("finished updating")

	wg.Wait()

}

package main

import (
    "fmt"
    "net/http"
    "flag"
    "log"
)

var portFlag = flag.Int("p",2121,"working port")

var staticfs = http.FileServer(http.Dir("/mnt"))

func main() {
    flag.Parse()
    port := fmt.Sprintf(":%d",*portFlag)
    //http.Handle("/", http.FileServer(http.Dir(dir)))
    http.HandleFunc("/", static)
    http.ListenAndServe(port, nil)
}

func static(w http.ResponseWriter, r *http.Request) {
    log.Printf("Access static file: %s\n", r.URL.Path)
    staticfs.ServeHTTP(w, r)
}

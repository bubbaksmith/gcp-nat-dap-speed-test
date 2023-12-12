package main

import (
	"fmt"
	"net/http"
	"sync"
	"time"
)

type RequestResult struct {
	ID       int
	Duration time.Duration
}

func makeRequest(url string, id int, wg *sync.WaitGroup, results chan RequestResult) {
	defer wg.Done()

	startTime := time.Now()

	resp, err := http.Get(url)
	if err != nil {
		fmt.Printf("Error making request: %v\n", err)
		return
	}
	defer resp.Body.Close()

	duration := time.Since(startTime)
	results <- RequestResult{ID: id, Duration: duration}
}

func main() {
	url := "https://ip-whitelist.calendly.com"
	numRequests := 1024

	var wg sync.WaitGroup
	results := make(chan RequestResult, numRequests)

	for i := 0; i < numRequests; i++ {
		wg.Add(1)
		go makeRequest(url, i, &wg, results)
	}

	go func() {
		wg.Wait()
		close(results)
	}()

	var requestResults []RequestResult
	for result := range results {
		requestResults = append(requestResults, result)
	}

	// Print the results
	for index, result := range requestResults {
		fmt.Printf("Request %d took: %v\n", index, result.Duration)
	}
}

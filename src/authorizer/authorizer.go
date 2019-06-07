package main

import (
  "github.com/aws/aws-lambda-go/lambda"
  "context"
  "fmt"
  "github.com/CodyPerakslis/kanetus-database-lib/auth"
)

type MyEvent struct {}

func main() {
  lambda.Start(HandleRequest)
}

func HandleRequest(ctx context.Context, event MyEvent) (string, error) {
  fmt.Println("Hello World")
  dk := auth.ConstructHash(2000, []byte("salty"), []byte("Hell World"))
  fmt.Println(dk)
  auth.ReadPassword([]byte("hello"), []byte("world"))
  auth.Test()
  return "Hello World", nil
}

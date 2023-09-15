package main

import (
	"fmt"

	_ "github.com/kong/kubernetes-telemetry/pkg/telemetry"
	_ "github.com/kong/kubernetes-testing-framework/pkg/environments"
)

func main() {
	fmt.Println("hello")
}

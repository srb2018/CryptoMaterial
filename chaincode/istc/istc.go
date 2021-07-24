package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SpecialtyTeaContract the Smart Contract structure
type SpecialtyTeaContract struct {
	contractapi.Contract
}

// TeaLot the letter of credit
type TeaLot struct {
	TeaLotID         string `json:"teaLotId"`
	TeaVariant       string `json:"teaVariant"`
	Origin           string `json:"origin"`
	Season           string `json:"season"`
	TeaEstate        string `json:"teaEstate"`
	TeaMaster        string `json:"teaMaster"`
	Make             string `json:"make"`
	LeafType         string `json:"leafType"`
	MadeTeaName      string `json:"madeTeaName"`
	SoilType         string `json:"soilType"`
	Characteristics  string `json:"characteristics"`
	TeaTasteNotes    string `json:"teaTasteNotes"`
	HealthAttributes string `json:"healthAttributes"`
	Certified        string `json:"certified"`
	Award            string `json:"award"`
	LotNumber        string `json:"lotNumber"`
	TeaTaster        string `json:"teaTaster"`
	LotStatus        string `json:"lotStatus"`
	LabStatus        string `json:"labStatus"`
	TastingStatus    string `json:"tastingStatus"`
	LabName          string `json:"labName"`
}

// TeaPacket the letter of credit
type TeaPacket struct {
	TeaPacketID          string `json:"teaPacketId"`
	TeaLotID             string `json:"teaLotId"`
	Quantity             int    `json:"quantity"`
	UOM                  string `json:"uom"`
	Status               string `json:"status"`
	BuyerName            string `json:"buyerName"`
	FreightNo            string `json:"freightNo"`
	LogisticsPartnerName string `json:"logisticsPartnerName"`
	IndianTarrifCode     string `json:"indianTarrifCode"`
}

// Init chaincode
func (s *SpecialtyTeaContract) Init(ctx contractapi.TransactionContextInterface) error {

	teaLots := []TeaLot{
		TeaLot{TeaLotID: "1", TeaVariant: "PurpleTea", Origin: "Karbi Anglong", Season: "Spring,First Flush", TeaEstate: "Barpathar Tea Estate", TeaMaster: "P.S", Make: "Wiry", LeafType: "Two Leaf and Bud", MadeTeaName: "WildPurple", SoilType: "Clay Soil", Characteristics: "Strong", TeaTasteNotes: "Fruity, Deep Red Purple Hue", HealthAttributes: "CardioVascular; UV Rays Protection", Certified: "No", Award: "", LotNumber: "L001", TeaTaster: "HS", LotStatus: "ReadyToSale", TastingStatus: "Completed"},
	}
	teaLotAsBytes, _ := json.Marshal(teaLots[0])
	ctx.GetStub().PutState("1", teaLotAsBytes)
	return nil
}

// Invoke Chaincode
func (s *SpecialtyTeaContract) Invoke(ctx contractapi.TransactionContextInterface) (string, error) {

	// Retrieve the requested Smart Contract function and arguments
	function, args := ctx.GetStub().GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "initLedger" {
		return s.InitLedger(ctx)
	} else if function == "CreateTeaLot" {
		return s.CreateTeaLot(ctx, args)
	} else if function == "createTeaPacket" {
		return s.createTeaPacket(ctx, args)
	} else if function == "updateTeaLot" {
		return s.updateTeaLot(ctx, args)
	} else if function == "updateTeaPacket" {
		return s.updateTeaPacket(ctx, args)
	} else if function == "initiateLabTest" {
		return s.initiateLabTest(ctx, args)
	} else if function == "updateLabResult" {
		return s.updateLabResult(ctx, args)
	} else if function == "initiateTeaTaste" {
		return s.initiateTeaTaste(ctx, args)
	} else if function == "updateTeaTaste" {
		return s.updateTeaTaste(ctx, args)
	} else if function == "getTeaLot" {
		return s.getTeaLot(ctx, args)
	} else if function == "getTeaLotHistory" {
		return s.getTeaLotHistory(ctx, args)
	} else if function == "queryAllTeaLots" {
		return s.queryAllTeaLots(ctx)
	} else if function == "queryAllTeaPackets" {
		return s.queryAllTeaPackets(ctx)
	} else if function == "getTeaPacket" {
		return s.getTeaPacket(ctx, args)
	} else if function == "getTeaPacketHistory" {
		return s.getTeaPacketHistory(ctx, args)
	}

	return "", fmt.Errorf("Invalid Smart Contract function name")
}

// InitLedger function
func (s *SpecialtyTeaContract) InitLedger(ctx contractapi.TransactionContextInterface) (string, error) {
	// Tea Lots
	teaLots := []TeaLot{
		TeaLot{TeaLotID: "1", TeaVariant: "PurpleTea", Origin: "Karbi Anglong", Season: "Spring,First Flush", TeaEstate: "Barpathar Tea Estate", TeaMaster: "P.S", Make: "Wiry", LeafType: "Two Leaf and Bud", MadeTeaName: "WildPurple", SoilType: "Clay Soil", Characteristics: "Strong", TeaTasteNotes: "Fruity, Deep Red Purple Hue", HealthAttributes: "CardioVascular; UV Rays Protection", Certified: "No", Award: "", LotNumber: "L001", TeaTaster: "HS", LotStatus: "ReadyToSale", TastingStatus: "Completed"},
		TeaLot{TeaLotID: "2", TeaVariant: "PurpleTea", Origin: "Karbi Anglong", Season: "Monsoon,Second Flush", TeaEstate: "Barpathar Tea Estate", TeaMaster: "P.S", Make: "Boutique", LeafType: "Two Leaf and Bud", MadeTeaName: "Moonsoon Rainbow", SoilType: "Clay Soil", Characteristics: "Strong", TeaTasteNotes: "Fruity", HealthAttributes: "CardioVascular; UV Rays Protection", Certified: "No", Award: "", LotNumber: "L002", TeaTaster: "HS", LotStatus: "ReadyToSale", TastingStatus: "Initiated"},
		TeaLot{TeaLotID: "3", TeaVariant: "PurpleTea", Origin: "Karbi Anglong", Season: "Autumn,Diwali", TeaEstate: "Barpathar Tea Estate", TeaMaster: "P.S", Make: "Wiry", LeafType: "Two Leaf and Bud", MadeTeaName: "Kartik Purnima Purple", SoilType: "Clay Soil", Characteristics: "Mild", TeaTasteNotes: "Sweet Purple", HealthAttributes: "CardioVascular; UV Rays Protection", Certified: "Yes", Award: "", LotNumber: "L003", TeaTaster: "HS", LotStatus: "Sold", TastingStatus: "Completed"},
		TeaLot{TeaLotID: "4", TeaVariant: "PurpleTea", Origin: "Karbi Anglong", Season: "Winter,First Flush", TeaEstate: "Barpathar Tea Estate", TeaMaster: "P.S", Make: "Shade Dry", LeafType: "Bud", MadeTeaName: "Velvet Smooth", SoilType: "Clay Soil", Characteristics: "Light", TeaTasteNotes: "Flowery", HealthAttributes: "Bone Health, Teeth Health, Collagen Building", Certified: "Yes", Award: "King of White Tea Title", LotNumber: "L004", TeaTaster: "HS", LotStatus: "ReadyToPack", TastingStatus: "Initiated"},
	}
	i := 0

	for i < len(teaLots) {
		fmt.Println("i is ", i)
		teaLotAsBytes, _ := json.Marshal(teaLots[i])
		ctx.GetStub().PutState(teaLots[i].TeaLotID, teaLotAsBytes)
		fmt.Println("Added", teaLots[i])
	}

	// Tea Packets
	teaPackets := []TeaPacket{
		TeaPacket{TeaPacketID: "1001", TeaLotID: "1", Quantity: 35, UOM: "gram", Status: "Ready", BuyerName: "Luke", FreightNo: "Requested", LogisticsPartnerName: "FedEx", IndianTarrifCode: "ITC09202120"},
		TeaPacket{TeaPacketID: "1002", TeaLotID: "1", Quantity: 35, UOM: "gram", Status: "Sold", BuyerName: "T2", FreightNo: "1263653", LogisticsPartnerName: "FedEx", IndianTarrifCode: "ITC09202120"},
		TeaPacket{TeaPacketID: "1003", TeaLotID: "2", Quantity: 100, UOM: "gram", Status: "Sold", BuyerName: "abc", FreightNo: "1263789", LogisticsPartnerName: "FedEx", IndianTarrifCode: "ITC09202121"},
		TeaPacket{TeaPacketID: "1004", TeaLotID: "3", Quantity: 100, UOM: "gram", Status: "Ready", BuyerName: "T2", FreightNo: "Requested", LogisticsPartnerName: "FedEx", IndianTarrifCode: "ITC09202122"},
	}

	i = 0

	for i < len(teaPackets) {
		fmt.Println("i is ", i)
		tpAsBytes, _ := json.Marshal(teaPackets[i])
		ctx.GetStub().PutState(teaPackets[i].TeaPacketID, tpAsBytes)
		fmt.Println("Added", teaPackets[i])
		i = i + 1
	}

	return "", nil
}

// This function is initiate by CreateTeaLot
func (s *SpecialtyTeaContract) CreateTeaLot(ctx contractapi.TransactionContextInterface, args []string) (string, error) {

	// if len(args) != 1 {
	// 	return "", fmt.Errorf("Incorrect number of arguments. creating TeaLot function must needed arguments")
	// }

	teaLot := TeaLot{}

	err := json.Unmarshal([]byte(args[0]), &teaLot)
	if err != nil {
		return "", fmt.Errorf("Not able to parse args into tea lot")
	}
	// pm := &map[string]string{"teaLot": teaLot.TeaLotID}

	// args := map[string]string { "1":"a", "2":"b" }
	// args := []string{"theatreName\":\"IMax Studios\",\"windows\":4,\"ticketsPerShow\":100,\"showsDaily\":4,\"sodaStock\":200,\"halls\":5"}

	// teaLots := TeaArg{
	// 	{TeaLotID: teaLot.TeaLotID},
	// }

	// exists, err := s.getTeaLot(ctx, teaLots)

	teaLotAsBytes, err := json.Marshal(teaLot)

	ctx.GetStub().PutState(teaLot.TeaLotID, teaLotAsBytes)
	fmt.Println("created Tea -> ", teaLot)

	return "Created Tea", nil
}

// This function is initiate by producer
func (s *SpecialtyTeaContract) createTeaPacket(ctx contractapi.TransactionContextInterface, args []string) (string, error) {

	tp := TeaPacket{}

	err := json.Unmarshal([]byte(args[0]), &tp)
	if err != nil {
		return "", fmt.Errorf("Not able to parse args into tea")
	}
	tpAsBytes, err := json.Marshal(tp)
	ctx.GetStub().PutState(tp.TeaPacketID, tpAsBytes)
	fmt.Println("created Tea Packet -> ", tp)

	return "Created Tea Packet", nil
}

func (s *SpecialtyTeaContract) updateTeaLot(ctx contractapi.TransactionContextInterface, args []string) (string, error) {

	teaLot := TeaLot{}

	err := json.Unmarshal([]byte(args[0]), &teaLot)
	if err != nil {
		return "", fmt.Errorf("Not able to parse args into tea")
	}
	teaLotAsBytes, err := json.Marshal(teaLot)
	ctx.GetStub().PutState(teaLot.TeaLotID, teaLotAsBytes)
	fmt.Println("updated Tea Lot -> ", teaLot)

	return "Updated Tea Lot", nil
}

func (s *SpecialtyTeaContract) updateTeaPacket(ctx contractapi.TransactionContextInterface, args []string) (string, error) {

	tp := TeaPacket{}

	err := json.Unmarshal([]byte(args[0]), &tp)
	if err != nil {
		return "", fmt.Errorf("Not able to parse args into tea")
	}
	tpAsBytes, err := json.Marshal(tp)
	ctx.GetStub().PutState(tp.TeaPacketID, tpAsBytes)
	fmt.Println("created Tea Packet -> ", tp)

	return "created Tea Packet", nil
}

//update lab name by producer, Lab
func (s *SpecialtyTeaContract) initiateLabTest(ctx contractapi.TransactionContextInterface, args []string) (string, error) {

	if len(args) != 2 {
		return "", fmt.Errorf("Incorrect number of arguments. Expecting only two arguments")
	}

	teaLotAsBytes, _ := ctx.GetStub().GetState(args[0])

	teaLot := TeaLot{}
	json.Unmarshal(teaLotAsBytes, &teaLot)
	teaLot.LabStatus = "Initiated"
	teaLot.LabName = args[1]
	teaLotAsBytes, _ = json.Marshal(teaLot)
	ctx.GetStub().PutState(teaLot.TeaLotID, teaLotAsBytes)
	fmt.Println("Update Tea taste-> ", teaLot)

	return "Initiated LAB Test", nil
}

func (s *SpecialtyTeaContract) updateLabResult(ctx contractapi.TransactionContextInterface, args []string) (string, error) {

	if len(args) != 2 {
		return "", fmt.Errorf("Incorrect number of arguments. Expecting only two arguments")
	}

	teaLotAsBytes, _ := ctx.GetStub().GetState(args[0])

	teaLot := TeaLot{}
	json.Unmarshal(teaLotAsBytes, &teaLot)
	teaLot.LabStatus = "Completed"
	teaLot.Certified = args[1]
	teaLotAsBytes, _ = json.Marshal(teaLot)
	ctx.GetStub().PutState(teaLot.TeaLotID, teaLotAsBytes)
	fmt.Println("Update Tea taste-> ", teaLot)

	return "Update Lab Result", nil
}

func (s *SpecialtyTeaContract) initiateTeaTaste(ctx contractapi.TransactionContextInterface, args []string) (string, error) {
	if len(args) != 2 {
		return "", fmt.Errorf("Incorrect number of arguments. Expecting only two args")
	}

	teaLotAsBytes, _ := ctx.GetStub().GetState(args[0])

	teaLot := TeaLot{}
	json.Unmarshal(teaLotAsBytes, &teaLot)
	teaLot.TastingStatus = "Initiated"
	teaLot.TeaTaster = args[1]
	teaLotAsBytes, _ = json.Marshal(teaLot)
	ctx.GetStub().PutState(teaLot.TeaLotID, teaLotAsBytes)
	fmt.Println("Update Tea taste-> ", teaLot)

	return "Initiate Tea Taste", nil
}

//update tea taste notes by producer, tea taster
func (s *SpecialtyTeaContract) updateTeaTaste(ctx contractapi.TransactionContextInterface, args []string) (string, error) {

	if len(args) != 2 {
		return "", fmt.Errorf("Incorrect number of arguments. Expecting only two arguments")
	}

	teaLotAsBytes, _ := ctx.GetStub().GetState(args[0])

	teaLot := TeaLot{}
	json.Unmarshal(teaLotAsBytes, &teaLot)
	teaLot.TastingStatus = "Completed"
	teaLot.TeaTasteNotes = args[1]
	teaLotAsBytes, _ = json.Marshal(teaLot)
	ctx.GetStub().PutState(teaLot.TeaLotID, teaLotAsBytes)
	fmt.Println("Update Tea taste-> ", teaLot)

	return "Update Tea taste", nil
}

func (s *SpecialtyTeaContract) getTeaLot(ctx contractapi.TransactionContextInterface, args []string) (string, error) {

	teaLotID := args[0]

	// if err != nil {
	// 	return shim.Error("No Amount")
	// }

	teaLotAsBytes, _ := ctx.GetStub().GetState(teaLotID)

	return string(teaLotAsBytes), nil
}

func (s *SpecialtyTeaContract) getTeaLotHistory(ctx contractapi.TransactionContextInterface, args []string) (string, error) {

	teaTypeID := args[0]

	resultsIterator, err := ctx.GetStub().GetHistoryForKey(teaTypeID)
	if err != nil {
		return "", fmt.Errorf("Error retrieving Tea history")
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the marble
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return "", fmt.Errorf("Error retrieving Tea history")
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		// if it was a delete operation on given key, then we need to set the
		//corresponding value null. Else, we will write the response.Value
		//as-is (as the Value itself a JSON marble)
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- getTeaHistory returning:\n%s\n", buffer.String())

	return string(buffer.Bytes()), nil
}

func (s *SpecialtyTeaContract) getTeaPacket(ctx contractapi.TransactionContextInterface, args []string) (string, error) {

	teaPacketID := args[0]

	// if err != nil {
	// 	return shim.Error("No Amount")
	// }

	teaPacketAsBytes, _ := ctx.GetStub().GetState(teaPacketID)

	return string(teaPacketAsBytes), nil
}

func (s *SpecialtyTeaContract) getTeaPacketHistory(ctx contractapi.TransactionContextInterface, args []string) (string, error) {

	teaTypeID := args[0]

	resultsIterator, err := ctx.GetStub().GetHistoryForKey(teaTypeID)
	if err != nil {
		return "", fmt.Errorf("Error retrieving Tea packet history")
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the marble
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return "", fmt.Errorf("Error retrieving Tea history")
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		// if it was a delete operation on given key, then we need to set the
		//corresponding value null. Else, we will write the response.Value
		//as-is (as the Value itself a JSON marble)
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- getTeaPacketHistory returning:\n%s\n", buffer.String())

	return string(buffer.Bytes()), nil
}

func (s *SpecialtyTeaContract) queryAllTeaLots(ctx contractapi.TransactionContextInterface) (string, error) {

	startKey := "TL001"
	endKey := "TL999"

	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)
	if err != nil {
		return "", fmt.Errorf(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return "", fmt.Errorf(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- queryAllTeas:\n%s\n", buffer.String())

	return string(buffer.Bytes()), nil
}

func (s *SpecialtyTeaContract) queryAllTeaPackets(ctx contractapi.TransactionContextInterface) (string, error) {

	startKey := "TP001"
	endKey := "TP999"

	resultsIterator, err := ctx.GetStub().GetStateByRange(startKey, endKey)
	if err != nil {
		return "", fmt.Errorf(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return "", fmt.Errorf(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- queryAllTeas:\n%s\n", buffer.String())

	return string(buffer.Bytes()), nil
}

// The main function is only relevant in unit test mode. Only included here for completeness.
func main() {

	chaincode, err := contractapi.NewChaincode(new(SpecialtyTeaContract))
	if err != nil {
		fmt.Printf("Error create SpecialtyTeaContract chaincode: %s", err.Error())
		return
	}
	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting SpecialtyTeaContract chaincode: %s", err.Error())
	}
}

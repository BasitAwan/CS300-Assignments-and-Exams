package main

import (
    "fmt"
    "os"
    "strconv"
    "math"
	"encoding/csv"
	"sync"
)

type CensusGroup struct {
	population int
	latitude, longitude float64
}
func paralQue(censusData []CensusGroup, totalPop chan int, Iwest float64, Ieast float64, Inorth float64, Isouth float64 ) {
	if len(censusData) < 1000{
		population:=0
		for i:= range censusData {
       			if censusData[i].latitude <= Inorth && censusData[i].latitude >= Isouth && censusData[i].longitude <= Ieast && censusData[i].longitude >= Iwest {
       				population = population + censusData[i].population

       				
       		}
       	}
       	totalPop<-population


	} else 
	{
		split:= len(censusData)/2
		totalpop1:= make (chan int)
		totalpop2:= make (chan int)
		censusData1 := censusData[split:]
		censusData2 := censusData[:split]
		go paralQue(censusData1,totalpop1, Iwest,Ieast,Inorth,Isouth)
		go paralQue(censusData2,totalpop2, Iwest,Ieast,Inorth,Isouth)
		total:= <-totalpop1 + <-totalpop2

		totalPop <-total
	}	
}

func paralSetup(censusData []CensusGroup, value chan []float64, totalPop chan int ) {
	up:=censusData[0].latitude
    down:=censusData[0].latitude
    left:=censusData[0].longitude
    right:=censusData[0].longitude 
    var total int
	if len(censusData) < 5000{
		for i:= range censusData {
        	total = total + censusData[i].population
        	if censusData[i].latitude> up{
        		up = censusData[i].latitude
        	}
        	if censusData[i].latitude<down {
        		down = censusData[i].latitude
        	}
        	if censusData[i].longitude > right {
        		right =censusData[i].longitude
        	}
        	if censusData[i].longitude < left {
        		left = censusData[i].longitude
        	}
        	


        }
        cord := []float64{up,down,right,left}
        value<- cord
       	totalPop<- total
        
	} else
	{
		split:= len(censusData)/2
		value1:= make (chan []float64)
		value2:= make (chan []float64)
		totalpop1:= make (chan int)
		totalpop2:= make (chan int)
		censusData1 := censusData[split:]
		censusData2 := censusData[:split]
		go paralSetup(censusData1,value1,totalpop1)
		go paralSetup(censusData2,value2,totalpop2)
		cord1 := <-value1
		cord2 := <-value2
		cord:= []float64{0,0,0,0}

		if cord1[0]>cord2[0] {
				cord[0] = cord1[0]
			} else 
			{
				cord[0] = cord2[0]
			}
		if cord1[1]<cord2[1] {
				cord[1] = cord1[1]
			} else 
			{
				cord[1] = cord2[1]
			}
		if cord1[2]>cord2[2] {
				cord[2] = cord1[2]
			} else 
			{
				cord[2] = cord2[2]
			}
		if cord1[3]<cord2[3] {
				cord[3] = cord1[3]
			} else 
			{
				cord[3] = cord2[3]
			}
		total:= <-totalpop1 + <-totalpop2
		value <- cord
		totalPop <-total

	}
}

func GridParal(censusData []CensusGroup,  grid [][]int, gridChan chan [][]int, up float64, down float64, left float64, right float64, xscale float64, yscale float64, xdim int , ydim int){
	if len(censusData) < 5000{
		for i:= range censusData {
        	y:=0
        	x:=0
        	for censusData[i].latitude >= down + yscale*float64(y) {
        		y++
        		if (censusData[i].latitude==up){
        			y = ydim
        			break
        		}
        	}
        	for censusData[i].longitude >= left + xscale*float64(x) {
        		x++
        		if (censusData[i].longitude==right){
        			x=xdim
        			break
        		}
        	}
       		// fmt.Println(y,x, down, up, censusData[i].latitude, left, censusData[i].longitude)
        	grid[y-1][x-1] += censusData[i].population
        }
        gridChan <-grid


	}else
	{
		split:= len(censusData)/2
		gridChan1:= make (chan [][]int)
		gridChan2:= make (chan [][]int)
		censusData1 := censusData[split:]
		censusData2 := censusData[:split]
		grid1 := make([][]int, ydim)
		for i := range grid1 {
		    grid1[i] = make([]int, xdim)
		}
	    for i := 0; i < ydim; i++ {
	    	for j := 0; j < xdim; j++ {
	    		grid1[i][j]= grid[i][j]
	    	}
	    }
	    grid2 := make([][]int, ydim)
		for i := range grid2 {
		    grid2[i] = make([]int, xdim)
		}
	    for i := 0; i < ydim; i++ {
	    	for j := 0; j < xdim; j++ {
	    		grid2[i][j]= grid[i][j]
	    	}
	    }
		go GridParal(censusData1, grid1, gridChan1,up,down,left,right,xscale,yscale,xdim,ydim)
		go GridParal(censusData2, grid2, gridChan2,up,down,left,right,xscale,yscale,xdim,ydim)
		<-gridChan1
		<-gridChan2
		for i := 0; i < ydim; i++ {
	    	for j := 0; j < xdim; j++ {
	    		grid[i][j]= grid1[i][j] + grid2[i][j]
	    	}
	    }
	    gridChan <- grid
	   


	}
}

func GridParal1(censusData []CensusGroup,  mu *sync.Mutex, grid [][]int, gridChan chan [][]int, up float64, down float64, left float64, right float64, xscale float64, yscale float64, dim []int ){
	xdim := dim[0]
	ydim := dim[1]
	if len(censusData) < 5000{
		for i:= range censusData {
        	y:=0
        	x:=0
        	for censusData[i].latitude >= down + yscale*float64(y) {
        		y++
        		if (censusData[i].latitude==up){
        			y = ydim
        			break
        		}
        	}
        	for censusData[i].longitude >= left + xscale*float64(x) {
        		x++
        		if (censusData[i].longitude==right){
        			x=xdim
        			break
        		}
        	}
       		// fmt.Println(y,x, down, up, censusData[i].latitude, left, censusData[i].longitude)
       		mu.Lock()
        	grid[y-1][x-1] += censusData[i].population
        	mu.Unlock()
        }
        gridChan <-grid


	}else
	{
		split:= len(censusData)/2
		gridChan1:= make (chan [][]int)
		gridChan2:= make (chan [][]int)
		censusData1 := censusData[split:]
		censusData2 := censusData[:split]
		go GridParal1(censusData1,mu, grid, gridChan1,up,down,left,right,xscale,yscale,dim)
		go GridParal1(censusData2,mu, grid, gridChan2,up,down,left,right,xscale,yscale,dim)
		<-gridChan1
		<-gridChan2
		gridChan <- grid

	}
}
func ParseCensusData(fname string) ([]CensusGroup, error) {
	file, err := os.Open(fname)
    if err != nil {
		return nil, err
    }
    defer file.Close()

	records, err := csv.NewReader(file).ReadAll()
	if err != nil {
		return nil, err
	}
	censusData := make([]CensusGroup, 0, len(records))

    for _, rec := range records {
        if len(rec) == 7 {
            population, err1 := strconv.Atoi(rec[4])
            latitude, err2 := strconv.ParseFloat(rec[5], 64)
            longitude, err3 := strconv.ParseFloat(rec[6], 64)
            if err1 == nil && err2 == nil && err3 == nil {
                latpi := latitude * math.Pi / 180
                latitude = math.Log(math.Tan(latpi) + 1 / math.Cos(latpi))
                censusData = append(censusData, CensusGroup{population, latitude, longitude})
            }
        }
    }

	return censusData, nil
}

func main () {
	if len(os.Args) < 4 {
		fmt.Printf("Usage:\nArg 1: file name for input data\nArg 2: number of x-dim buckets\nArg 3: number of y-dim buckets\nArg 4: -v1, -v2, -v3, -v4, -v5, or -v6\n")
		return
	}
	fname, ver := os.Args[1], os.Args[4]
    xdim, err := strconv.Atoi(os.Args[2])
	if err != nil {
		fmt.Println(err)
		return
	}
    ydim, err := strconv.Atoi(os.Args[3])
	if err != nil {
		fmt.Println(err)
		return
	}
	censusData, err := ParseCensusData(fname)
	if err != nil {
		fmt.Println(err)
		return
	}

    // Some parts may need no setup code
    up:=censusData[0].latitude
    down:=censusData[0].latitude
    left:=censusData[0].longitude
    right:=censusData[0].longitude 
    var xscale, yscale float64
    var total int
    grid := make([][]int, ydim)
	for i := range grid {
	    grid[i] = make([]int, xdim)
	}
    for i := 0; i < ydim; i++ {
    	for j := 0; j < xdim; j++ {
    		grid[i][j]= 0
    	}
    }
    switch ver {
    case "-v1":
        for i:= range censusData {
        	total = total + censusData[i].population
        	if censusData[i].latitude> up{
        		up = censusData[i].latitude
        	}
        	if censusData[i].latitude<down {
        		down = censusData[i].latitude
        	}
        	if censusData[i].longitude > right {
        		right =censusData[i].longitude
        	}
        	if censusData[i].longitude < left {
        		left = censusData[i].longitude
        	}

        }
        xscale = (right-left)/float64(xdim)
        yscale = (up-down)/float64(ydim)
    case "-v2":
    	value:= make (chan []float64)
		totalpop:= make (chan int)
		go paralSetup(censusData,value,totalpop)
		cord:= <-value
		total= <-totalpop
		up = cord[0]
		down= cord[1]
		right= cord[2]
		left=cord[3]
		xscale = (right-left)/float64(xdim)
        yscale = (up-down)/float64(ydim)

       
    case "-v3":
        value:= make (chan []float64)
		totalpop:= make (chan int)
		go paralSetup(censusData,value,totalpop)
		cord:= <-value
		total= <-totalpop
		up = cord[0]
		down= cord[1]
		right= cord[2]
		left=cord[3]
		xscale = (right-left)/float64(xdim)
        yscale = (up-down)/float64(ydim)
        for i:= range censusData {
        	y:=0
        	x:=0
        	for censusData[i].latitude >= down + yscale*float64(y) {
        		y++
        		if (censusData[i].latitude==up){
        			y = ydim
        			break
        		}
        	}
        	for censusData[i].longitude >= left + xscale*float64(x) {
        		x++
        		if (censusData[i].longitude==right){
        			x=xdim
        			break
        		}
        	}
       		// fmt.Println(y,x, down, up, censusData[i].latitude, left, censusData[i].longitude)
        	grid[y-1][x-1] += censusData[i].population
        }
       	for i := ydim-1; i >= 0; i-- {
       		for j := 0; j < xdim; j++ {
       			if j>0 {
       				grid[i][j]+= grid[i][j-1]
       			}
       			if i<ydim-1 {
       				grid[i][j]+= grid[i+1][j]
       			}
       			if j>0 && i<ydim-1 {
       				grid[i][j] -= grid[i+1][j-1]
       			}
       		}
       		
       	}

    case "-v4":
        value:= make (chan []float64)
		totalpop:= make (chan int)
		go paralSetup(censusData,value,totalpop)
		cord:= <-value
		total= <-totalpop
		up = cord[0]
		down= cord[1]
		right= cord[2]
		left=cord[3]
		xscale = (right-left)/float64(xdim)
        yscale = (up-down)/float64(ydim)
		gridChan:= make (chan [][]int)
		go GridParal(censusData, grid, gridChan,up,down,left,right,xscale,yscale,xdim,ydim)
		<-gridChan
		for i := ydim-1; i >= 0; i-- {
       		for j := 0; j < xdim; j++ {
       			if j>0 {
       				grid[i][j]+= grid[i][j-1]
       			}
       			if i<ydim-1 {
       				grid[i][j]+= grid[i+1][j]
       			}
       			if j>0 && i<ydim-1 {
       				grid[i][j] -= grid[i+1][j-1]
       			}
       		}
       		
       	}
    case "-v5":
        value:= make (chan []float64)
		totalpop:= make (chan int)
		go paralSetup(censusData,value,totalpop)
		cord:= <-value
		total= <-totalpop
		up = cord[0]
		down= cord[1]
		right= cord[2]
		left=cord[3]
		xscale = (right-left)/float64(xdim)
        yscale = (up-down)/float64(ydim)
		gridChan:= make (chan [][]int)
		var mu sync.Mutex
		dim:= []int{xdim,ydim}
		go GridParal1(censusData, &mu, grid, gridChan,up,down,left,right,xscale,yscale,dim)
		<-gridChan
		for i := ydim-1; i >= 0; i-- {
       		for j := 0; j < xdim; j++ {
       			if j>0 {
       				grid[i][j]+= grid[i][j-1]
       			}
       			if i<ydim-1 {
       				grid[i][j]+= grid[i+1][j]
       			}
       			if j>0 && i<ydim-1 {
       				grid[i][j] -= grid[i+1][j-1]
       			}
       		}
       		
       	}
    case "-v6":
        // YOUR SETUP CODE FOR PART 6
    default:
        fmt.Println("Invalid version argument")
        return
    }

    for {
        var west, south, east, north int
        n, err := fmt.Scanln(&west, &south, &east, &north)
        if n != 4 || err != nil || west<1 || west>xdim || south<1 || south>ydim || east<west || east>xdim || north<south || north>ydim {
            break
        }

        var population int
        var percentage float64
        switch ver {
        case "-v1":
        	Iwest := left + ((float64(west-1))*xscale) 
       		Ieast := left + (float64((east))*xscale) 
       		Inorth := down + (float64((north))*yscale) 
       		Isouth := down + (float64((south-1))*yscale)
       		population = 0

       		for i:= range censusData {
       			if censusData[i].latitude <= Inorth && censusData[i].latitude >= Isouth && censusData[i].longitude <= Ieast && censusData[i].longitude >= Iwest {
       				population = population + censusData[i].population

       				
       			}
       		}

       		percentage =(float64(population)/float64(total))*100
            // YOUR QUERY CODE FOR PART 1
        case "-v2":
        	Iwest := left + ((float64(west-1))*xscale) 
       		Ieast := left + (float64((east))*xscale) 
       		Inorth := down + (float64((north))*yscale) 
       		Isouth := down + (float64((south-1))*yscale)
			totalpop:= make (chan int)
       		go paralQue(censusData,totalpop,Iwest,Ieast,Inorth,Isouth)
       		population = <-totalpop
       		percentage =(float64(population)/float64(total))*100
            // YOUR QUERY CODE FOR PART 2
        case "-v3":
            // YOUR QUERY CODE FOR PART 3
            population = grid[south-1][east-1]

            if north<ydim-1 {
            	population-= grid[north][east-1]
            }
            if west-1>0 {
            	population-= grid[south-1][west-2]
            }
            if north<ydim-1 && west-1>0{
            	population+= grid[north][west-2]
            }
       		percentage =(float64(population)/float64(total))*100
        case "-v4":
            population = grid[south-1][east-1]

            if north<ydim-1 {
            	population-= grid[north][east-1]
            }
            if west-1>0 {
            	population-= grid[south-1][west-2]
            }
            if north<ydim-1 && west-1>0{
            	population+= grid[north][west-2]
            }
       		percentage =(float64(population)/float64(total))*100
        case "-v5":
             population = grid[south-1][east-1]

            if north<ydim-1 {
            	population-= grid[north][east-1]
            }
            if west-1>0 {
            	population-= grid[south-1][west-2]
            }
            if north<ydim-1 && west-1>0{
            	population+= grid[north][west-2]
            }
       		percentage =(float64(population)/float64(total))*100
        case "-v6":
            // YOUR QUERY CODE FOR PART 6
        }

        fmt.Printf("%v %.2f%%\n", population, percentage)
    }
}

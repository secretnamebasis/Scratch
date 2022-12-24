Marketplace Contract

Function ListProduct(productName String, price Uint64, sellerAddress String) 
// Check if product already exists 
10 IF EXISTS(productName) THEN RETURN 1 // return error if product already exists
// Store product details in DB 
20 STORE(productName, price) 
30 STORE(productName + "_seller", sellerAddress) // Add product to list of available products 
40 LET productList = LOAD("products") 
50 productList = productList + "," + productName 
60 STORE("products", productList) 
70 RETURN 0 // return success

Function CheckProductAvailability(productName String)
// Check if product exists
10 IF EXISTS(productName) THEN
20 RETURN 1 // product is available
30 ELSE
40 RETURN 0 // product is not available
50 End If
End Function

Function GetProductDetails(productName String)
// Retrieves the details of a specific product 
// Input: productName 
// Output: product details (name, price, seller address) 
    // Check if product exists
10    IF NOT EXISTS(productName) THEN RETURN "Product does not exist"
    // Retrieve product details from DB
20    LET price = LOAD(productName)
30    LET sellerAddress = LOAD(productName + "_seller")   
    // Return product details
40    RETURN "Product Name: " + productName + ", Price: " + price + ", Seller Address: " + sellerAddress
End Function

Function PurchaseProduct(productName String, buyerAddress String)
// Initiates a purchase of a product 
// Input: productName, buyerAddress 
// Output: success or error 
    // Check if product is available for purchase
10    IF CheckProductAvailability(productName) == 0 THEN RETURN 1 // return error if product is not available   
    // Get product details
20    Dim productDetails As String = GetProductDetails(productName)
    // Confirm purchase with buyer
    // TODO: implement mechanism to confirm purchase with buyer
    // Add funds to escrow
30    Dim price As Uint64 = productDetails[1]
40    AddFundsToEscrow(productName, productDetails[2], price)    
50    RETURN 0 // return success
End Function

Function PurchaseProduct(productName String, buyerAddress String)
    // Check if product is available
 10   IF !CheckProductAvailability(productName) THEN RETURN 1 // return error if product is not available

    // Get product details
20    let productDetails = GetProductDetails(productName)
30    let price = productDetails[1]
40    let sellerAddress = productDetails[2]
 
   // Add funds to escrow
50    IF !AddFundsToEscrow(productName, sellerAddress, price) THEN RETURN 2 // return error if unable to add funds to escrow

    // Confirm purchase with buyer
60    IF !ConfirmPurchase(productName, buyerAddress) THEN RETURN 3 // return error if purchase is not confirmed by buyer

70    RETURN 0 // return success
End Function

Function WithdrawFunds(amount Uint64, address String)
    // Check if address is valid
10    IF IS_ADDRESS_VALID(address) == 0 THEN RETURN 1 // return error if address is not valid

    // Check if SC has sufficient balance to withdraw
20    IF DEROVALUE() < amount THEN RETURN 2 // return error if SC does not have sufficient balance

    // Withdraw funds
30    SEND_DERO_TO_ADDRESS(address, amount)

40    RETURN 0 // return success
End Function

Function ConfirmPurchase(productName String, buyerAddress String)

// Check if product exists
10    IF NOT EXISTS(productName) THEN RETURN 1 // return error if product does not exist // Check if buyer is the one who initiated the purchase
20    IF LOAD(productName + "_buyer") != buyerAddress THEN RETURN 2 // return error if buyer address does not match

// Update product details in DB
30    STORE(productName + "_buyer", buyerAddress)
40    STORE(productName + "_status", "purchased")

50    RETURN 0 // return success
End Function 

Function ReleaseEscrow(productName String, sellerAddress String) // Check if product exists IF NOT EXISTS(productName) THEN RETURN 1 // return error if product does not exist

// Check if seller address matches the seller address stored in the contract IF LOAD(productName + "_seller") != sellerAddress THEN RETURN 2 // return error if seller address does not match

// Check if product has been purchased and shipped 
IF LOAD(productName + "_status") != "shipped" THEN RETURN 3 // return error if product has not been shipped

// Get escrowed funds and release to seller 
LET escrowedFunds = LOAD(productName + "_escrow") SEND(sellerAddress, escrowedFunds)

// Update product details in DB 
STORE(productName + "_status", "released")

// Pay contract owner a 0.3% fee 
LET fee = escrowedFunds * 0.003 SEND(LOAD("contract_owner"), fee)

RETURN 0 // return success End Function


Function ConfirmShipment(productName String, sellerAddress String) 
// Check if product exists 
IF NOT EXISTS(productName) THEN RETURN 1 
// return error if product does not exist
// Check if seller address matches
IF LOAD(productName + "_seller") != sellerAddress THEN RETURN 2 // return error if seller address does not match

// Update product status in DB
STORE(productName + "_status", "shipped")

RETURN 0 // return success
End Function

Function ConfirmReceipt(productName String, buyerAddress String) 
// Check if product exists 
IF NOT EXISTS(productName) THEN RETURN 1 
// return error if product does not exist 
// Check if buyer is the one who purchased the product 
IF LOAD(productName + "_buyer") != buyerAddress THEN RETURN 2 
// return error if buyer address does not match
// Update product status in DB STORE(productName + "_status", "received") 
RETURN 0 // return success 
End Function



Function RequestRefund(productName String, buyerAddress String) 
// Check if product exists  
IF NOT EXISTS(productName) THEN RETURN 1 
// return error if product does not exist
// Check if buyer is the one who initiated the purchase 
IF LOAD(productName + "_buyer") != buyerAddress THEN RETURN 2 
// return error if buyer address does not match 
// Check if product has already been refunded 
IF LOAD(productName + "_status") == "refunded" THEN RETURN 3 
// return error if product has already been refunded 
// Update product details in DB STORE(productName + "_status", "refund_requested") 
RETURN 0 // return success 
End Function



Function ApproveRefund(productName String, buyerAddress String) 
// Check if product exists 
IF NOT EXISTS(productName) THEN RETURN 1 
// return error if product does not exist
// Check if refund request exists for this product 
IF NOT EXISTS(productName + "_refund_request") THEN RETURN 2 
// return error if no refund request exists 
// Check if buyer initiated the refund request IF LOAD(productName + "_refund_request_buyer") != buyerAddress THEN RETURN 3 
// return error if buyer address does not match 
// Check if product has already been refunded 
IF LOAD(productName + "_status") == "refunded" THEN RETURN 4 
// return error if product has already been refunded 
// Release escrowed funds to buyer 
RELEASE_ESCROW(productName, buyerAddress) 
// Update product details in DB STORE(productName + "_status", "refunded") 
RETURN 0 // return success 
End Function

Function ProcessRefund(productName String, buyerAddress String) 
// Processes a refund for a product purchase 
// Input: productName, buyerAddress 
// Output: success or error
// Check if refund request has been approved
IF LOAD(productName + "_refund_status") != "approved" THEN RETURN 1 // return error if refund has not been approved

// Check if product has been shipped
IF LOAD(productName + "_status") != "shipped" THEN RETURN 2 // return error if product has not been shipped

// Check if product has been received
IF LOAD(productName + "_status") != "received" THEN RETURN 3 // return error if product has not been received

// Retrieve price of product
LET price = LOAD(productName + "_price")

// Retrieve escrowed funds
LET escrow = LOAD(productName + "_escrow")

// Calculate refund amount
LET refundAmount = escrow - price

// Update product details in DB
STORE(productName + "_status", "refunded")
STORE(productName + "_escrow", 0)

// Transfer refund to buyer
TRANSFER(buyerAddress, refundAmount)

RETURN 0 // return success
End Function


Function CancelRefund(productName String, buyerAddress String) 
// Cancels a refund request for a product purchase 
// Input: productName, buyerAddress 
// Output: success or error

// Check if product exists IF NOT EXISTS(productName) THEN RETURN 1 // return error if product does not exist

// Check if buyer is the one who initiated the refund request IF LOAD(productName + "_refund_buyer") != buyerAddress THEN RETURN 2 // return error if buyer address does not match

// Update product details in DB STORE(productName + "_refund_buyer", "") STORE(productName + "_refund_status", "cancelled")

RETURN 0 // return success End Function



Function RemoveProduct(productName String, sellerAddress String)
  // Removes a product from the market place
  // Input: productName, sellerAddress
  // Output: success or error

  // Check if product exists
  IF NOT EXISTS(productName) THEN RETURN 1 // return error if product does not exist

  // Check if seller is the owner of the product
  IF LOAD(productName + "_seller") != sellerAddress THEN RETURN 2 // return error if seller address does not match

  // Remove product from DB
  DELETE(productName)

  RETURN 0 // return success
End Function


Function GetProductList()
  // Retrieves a list of all products available for purchase
  // Input: none
  // Output: list of products
  
  // Initialize empty list to store product names
  productList = []
  
  // Iterate through all stored key-value pairs in the database
  FOR each key IN DB
    // If the key starts with "product_", it is a product name
    IF key.StartsWith("product_") THEN
      // Add the product name to the list
      productList.Add(key.Substring(8)) // 8 is the length of "product_"
  END FOR
  
  // Return the list of product names
  RETURN productList
End Function

Function GetBuyerList() 
buyersList = [] 
// initialize an empty list to store the buyers 
// iterate through all the products in the marketplace For product in marketplace 
// check if the product has been purchased If LOAD(product + "_status") == "purchased" 
// if the product has been purchased, retrieve the buyer address buyerAddress = LOAD(product + "_buyer") 
// add the buyer address to the buyers list buyersList.append(buyerAddress) End If Next 
// return the buyers list Return buyersList End Function

Function GetSellerList()
  // Retrieves a list of all sellers who have listed products for sale
  // Input: none
  // Output: list of sellers

  sellerList []String // array to store the list of sellers

  // Iterate through all products in the marketplace
  For product in marketplace
    sellerAddress = LOAD(product + "_seller") // retrieve the seller address for the product
    sellerList.Add(sellerAddress) // add the seller to the list
  End For

  Return sellerList // return the list of sellers
End Function

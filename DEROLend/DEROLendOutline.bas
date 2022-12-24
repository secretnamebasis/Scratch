' Function to initialize the pool
FUNCTION initialize()
    ' Check that pool has not already been initialized
10    IF EXISTS(SCID()) THEN RETURN 1
    
    ' Accept input of owner address and pool parameters
20    DIM ownerAddress as String
30    DIM borrowRate as Uint64
40    DIM maintenanceMargin as Uint64
42    ownerAddress = LOAD("ownerAddress")
44    borrowRate = LOAD("borrowRate")
46    maintenanceMargin = LOAD("maintenanceMargin")
    
    ' Validate input
50    IF !IS_ADDRESS_VALID(ownerAddress) THEN RETURN 2
60    IF borrowRate <= 0 THEN RETURN 3
70    IF maintenanceMargin <= 0 THEN RETURN 4
    
    ' Set pool parameters and owner
80    BORROW_RATE = borrowRate
90    MAINTENANCE_MARGIN = maintenanceMargin
100    OWNER = ownerAddress
    
    ' Return success message
101    RETURN 0
END FUNCTION

' Function to deposit collateral into the pool
FUNCTION deposit()
    ' Accept input of collateral asset and amount
10    DIM asset as Uint64
20    DIM amount as Uint64
23    asset = LOAD("asset")
26    amount = LOAD("amount")
    
    ' Validate input
30    IF asset <= 0 THEN RETURN 1
40    IF amount <= 0 THEN RETURN 2
    
    ' Check that user has sufficient balance of collateral asset
50    DIM balance as Uint64
55    balance = TOKENVALUE(asset, SCID())
60    IF balance < amount THEN RETURN 3
    
    ' Update user's balance and pool's total collateral
70    ADD_VALUE(asset, SCID(), -amount)
80    ADD_VALUE(asset, SCID(), amount)
    
    ' Return success message
90    RETURN 0
END FUNCTION


' Function to withdraw collateral from the pool
FUNCTION withdraw()
    ' Accept input of collateral asset and amount
10    DIM asset as Uint64
20    DIM amount as Uint64
23    asset = LOAD("asset")
26    amount = LOAD("amount")
    
    ' Validate input
30    IF asset <= 0 THEN RETURN 1
40    IF amount <= 0 THEN RETURN 2
    
    ' Check that user has sufficient collateral in the pool
50    DIM balance as Uint64
55    balance = TOKENVALUE(asset, SCID())
60    IF balance < amount THEN RETURN 3
    
    ' Update user's balance and pool's total collateral
70    ADD_VALUE(asset, SCID(), -amount)
80    ADD_VALUE(asset, SCID(), amount)
    
    ' Return success message
90    RETURN 0
END FUNCTION


' Function to borrow an asset from the pool
FUNCTION borrow()
    ' Accept input of borrowed asset and amount
10    DIM asset as Uint64
20    DIM amount as Uint64
23    asset = LOAD("asset")
26    amount = LOAD("amount")
    
    ' Validate input
30    IF asset <= 0 THEN RETURN 1
40    IF amount <= 0 THEN RETURN 2
    
    ' Check that pool has sufficient supply of borrowed asset
50    DIM supply as Uint64
55    supply = TOKENVALUE(asset, SCID())
60    IF supply < amount THEN RETURN 3
    
    ' Check that user has sufficient collateral to cover the borrow
70    DIM collateral as Uint64
75    collateral = TOKENVALUE(COLLATERAL_ASSET, SCID())
80    DIM requiredCollateral as Uint64
85    requiredCollateral = BORROW_RATE * amount
90    IF collateral < requiredCollateral THEN RETURN 4
    
    ' Update user's balance and pool's total borrowed assets and total collateral
100    ADD_VALUE(asset, SCID(), amount)
110    ADD_VALUE(asset, SCID(), -amount)
120    ADD_VALUE(COLLATERAL_ASSET, SCID(), -requiredCollateral)
130    ADD_VALUE(COLLATERAL_ASSET, SCID(), requiredCollateral)
    
    ' Return success message
140    RETURN 0
END FUNCTION


' Function to repay a borrowed asset
FUNCTION repay()
    ' Accept input of borrowed asset and amount
10    DIM asset as Uint64
20    DIM amount as Uint64
23    asset = LOAD("asset")
26    amount = LOAD("amount")
    
    ' Validate input
30    IF asset <= 0 THEN RETURN 1
40    IF amount <= 0 THEN RETURN 2
    
    ' Check that user has sufficient balance of borrowed asset
50    DIM balance as Uint64
55    balance = TOKENVALUE(asset, SCID())
60    IF balance < amount THEN RETURN 3
    
    ' Update user's balance and pool's total borrowed assets and total collateral
70    ADD_VALUE(asset, SCID(), -amount)
80    ADD_VALUE(asset, SCID(), amount)
    
    ' Return success message
90    RETURN 0
END FUNCTION


' Function to liquidate a user's collateral
FUNCTION liquidate()
    ' Accept input of user's address
10    DIM userAddress as String
15    userAddress = LOAD("userAddress")
    
    ' Validate input
20    IF !IS_ADDRESS_VALID(userAddress) THEN RETURN 1
    
    ' Check that user has sufficient collateral in the pool
20    DIM collateral as Uint64
25    collateral = TOKENVALUE(COLLATERAL_ASSET, userAddress)
30    IF collateral <= 0 THEN RETURN 2
    
    ' Check that user's collateral has fallen below the maintenance margin
40    DIM borrowed as Uint64
45    borrowed = TOKENVALUE(BORROWED_ASSET, userAddress)
50    DIM requiredCollateral as Uint64
55    requiredCollateral = BORROW_RATE * borrowed
60    IF collateral >= requiredCollateral * MAINTENANCE_MARGIN THEN RETURN 3
    
    ' Sell user's collateral on the market
70    DIM sellPrice as Uint64
75    sellPrice = MARKET_PRICE(COLLATERAL_ASSET)
80    DIM sellAmount as Uint64
85    sellAmount = collateral
90    SEND_DERO_TO_ADDRESS(ADDRESS_RAW(userAddress), sellAmount * sellPrice)

    ' Update user's balance and pool's total collateral
100    ADD_VALUE(COLLATERAL_ASSET, userAddress, -collateral)
110    ADD_VALUE(COLLATERAL_ASSET, SCID(), collateral)
    
    ' Return success message
120    RETURN 0
END FUNCTION


' Function to set pool parameters
FUNCTION setParameters()
    ' Check that caller is owner of the pool
10    DIM caller as String
15    caller = SIGNER()
20    IF caller != OWNER THEN RETURN 1
    
    ' Accept input of new parameters
30    DIM newBorrowRate as Uint64
40    DIM newMaintenanceMargin as Uint64
43    newBorrowRate = LOAD("borrowRate")
46    newMaintenanceMargin = LOAD("maintenanceMargin")
    
    ' Validate input
50    IF newBorrowRate <= 0 THEN RETURN 2
60    IF newMaintenanceMargin <= 0 THEN RETURN 3
    
    ' Update pool parameters
70    BORROW_RATE = newBorrowRate
80    MAINTENANCE_MARGIN = newMaintenanceMargin
    
    ' Return success message
90    RETURN 0
END FUNCTION


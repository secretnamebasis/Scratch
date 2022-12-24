' Function to initialize the pool
FUNCTION initialize()
    ' Check that pool has not already been initialized
    IF EXISTS(SCID()) THEN RETURN 1
    
    ' Accept input of owner address and pool parameters
    DIM ownerAddress as String
    DIM borrowRate as Uint64
    DIM maintenanceMargin as Uint64
    ownerAddress = LOAD("ownerAddress")
    borrowRate = LOAD("borrowRate")
    maintenanceMargin = LOAD("maintenanceMargin")
    
    ' Validate input
    IF !IS_ADDRESS_VALID(ownerAddress) THEN RETURN 2
    IF borrowRate <= 0 THEN RETURN 3
    IF maintenanceMargin <= 0 THEN RETURN 4
    
    ' Set pool parameters and owner
    BORROW_RATE = borrowRate
    MAINTENANCE_MARGIN = maintenanceMargin
    OWNER = ownerAddress
    
    ' Return success message
    RETURN 0
END FUNCTION

' Function to deposit collateral into the pool
FUNCTION deposit()
    ' Accept input of collateral asset and amount
    DIM asset as Uint64
    DIM amount as Uint64
    asset = LOAD("asset")
    amount = LOAD("amount")
    
    ' Validate input
    IF asset <= 0 THEN RETURN 1
    IF amount <= 0 THEN RETURN 2
    
    ' Check that user has sufficient balance of collateral asset
    DIM balance as Uint64
    balance = TOKENVALUE(asset, SCID())
    IF balance < amount THEN RETURN 3
    
    ' Update user's balance and pool's total collateral
    ADD_VALUE(asset, SCID(), -amount)
    ADD_VALUE(asset, SCID(), amount)
    
    ' Return success message
    RETURN 0
END FUNCTION


' Function to withdraw collateral from the pool
FUNCTION withdraw()
    ' Accept input of collateral asset and amount
    DIM asset as Uint64
    DIM amount as Uint64
    asset = LOAD("asset")
    amount = LOAD("amount")
    
    ' Validate input
    IF asset <= 0 THEN RETURN 1
    IF amount <= 0 THEN RETURN 2
    
    ' Check that user has sufficient collateral in the pool
    DIM balance as Uint64
    balance = TOKENVALUE(asset, SCID())
    IF balance < amount THEN RETURN 3
    
    ' Update user's balance and pool's total collateral
    ADD_VALUE(asset, SCID(), -amount)
    ADD_VALUE(asset, SCID(), amount)
    
    ' Return success message
    RETURN 0
END FUNCTION


' Function to borrow an asset from the pool
FUNCTION borrow()
    ' Accept input of borrowed asset and amount
    DIM asset as Uint64
    DIM amount as Uint64
    asset = LOAD("asset")
    amount = LOAD("amount")
    
    ' Validate input
    IF asset <= 0 THEN RETURN 1
    IF amount <= 0 THEN RETURN 2
    
    ' Check that pool has sufficient supply of borrowed asset
    DIM supply as Uint64
    supply = TOKENVALUE(asset, SCID())
    IF supply < amount THEN RETURN 3
    
    ' Check that user has sufficient collateral to cover the borrow
    DIM collateral as Uint64
    collateral = TOKENVALUE(COLLATERAL_ASSET, SCID())
    DIM requiredCollateral as Uint64
    requiredCollateral = BORROW_RATE * amount
    IF collateral < requiredCollateral THEN RETURN 4
    
    ' Update user's balance and pool's total borrowed assets and total collateral
    ADD_VALUE(asset, SCID(), amount)
    ADD_VALUE(asset, SCID(), -amount)
    ADD_VALUE(COLLATERAL_ASSET, SCID(), -requiredCollateral)
    ADD_VALUE(COLLATERAL_ASSET, SCID(), requiredCollateral)
    
    ' Return success message
    RETURN 0
END FUNCTION


' Function to repay a borrowed asset
FUNCTION repay()
    ' Accept input of borrowed asset and amount
    DIM asset as Uint64
    DIM amount as Uint64
    asset = LOAD("asset")
    amount = LOAD("amount")
    
    ' Validate input
    IF asset <= 0 THEN RETURN 1
    IF amount <= 0 THEN RETURN 2
    
    ' Check that user has sufficient balance of borrowed asset
    DIM balance as Uint64
    balance = TOKENVALUE(asset, SCID())
    IF balance < amount THEN RETURN 3
    
    ' Update user's balance and pool's total borrowed assets and total collateral
    ADD_VALUE(asset, SCID(), -amount)
    ADD_VALUE(asset, SCID(), amount)
    
    ' Return success message
    RETURN 0
END FUNCTION


' Function to liquidate a user's collateral
FUNCTION liquidate()
    ' Accept input of user's address
    DIM userAddress as String
    userAddress = LOAD("userAddress")
    
    ' Validate input
    IF !IS_ADDRESS_VALID(userAddress) THEN RETURN 1
    
    ' Check that user has sufficient collateral in the pool
    DIM collateral as Uint64
    collateral = TOKENVALUE(COLLATERAL_ASSET, userAddress)
    IF collateral <= 0 THEN RETURN 2
    
    ' Check that user's collateral has fallen below the maintenance margin
    DIM borrowed as Uint64
    borrowed = TOKENVALUE(BORROWED_ASSET, userAddress)
    DIM requiredCollateral as Uint64
    requiredCollateral = BORROW_RATE * borrowed
    IF collateral >= requiredCollateral * MAINTENANCE_MARGIN THEN RETURN 3
    
    ' Sell user's collateral on the market
    DIM sellPrice as Uint64
    sellPrice = MARKET_PRICE(COLLATERAL_ASSET)
    DIM sellAmount as Uint64
    sellAmount = collateral
    SEND_DERO_TO_ADDRESS(ADDRESS_RAW(userAddress), sellAmount * sellPrice)

    ' Update user's balance and pool's total collateral
    ADD_VALUE(COLLATERAL_ASSET, userAddress, -collateral)
    ADD_VALUE(COLLATERAL_ASSET, SCID(), collateral)
    
    ' Return success message
    RETURN 0
END FUNCTION


' Function to set pool parameters
FUNCTION setParameters()
    ' Check that caller is owner of the pool
    DIM caller as String
    caller = SIGNER()
    IF caller != OWNER THEN RETURN 1
    
    ' Accept input of new parameters
    DIM newBorrowRate as Uint64
    DIM newMaintenanceMargin as Uint64
    newBorrowRate = LOAD("borrowRate")
    newMaintenanceMargin = LOAD("maintenanceMargin")
    
    ' Validate input
    IF newBorrowRate <= 0 THEN RETURN 2
    IF newMaintenanceMargin <= 0 THEN RETURN 3
    
    ' Update pool parameters
    BORROW_RATE = newBorrowRate
    MAINTENANCE_MARGIN = newMaintenanceMargin
    
    ' Return success message
    RETURN 0
END FUNCTION


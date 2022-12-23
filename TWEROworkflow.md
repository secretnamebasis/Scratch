``` mermaid
sequenceDiagram
participant UserA as User A
participant TWERO as TWERO
participant DERO as DERO
participant UserB as User B

UserA->>DERO: Authenticate
DERO-->>UserA: Authenticate successful
UserA->>DERO: Send DERO to UserB
DERO->>UserB: Receive DERO
TWERO->>Twitter: Generate tweet "@userA sent a twero msg to @userB"

Note right of TWERO: TWERO uses DERO API to facilitate transactions and generates tweets to update users on activity
Note right of DERO: DERO securely processes transactions between users
Note right of UserA: UserA can send DERO to other users and update their followers on Twitter through TWERO
Note right of UserB: UserB receives DERO through secure transactions processed by DERO
```

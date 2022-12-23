``` mermaid
sequenceDiagram
participant TWERO as TWERO
participant DERO as DERO
participant Twitter as Twitter
participant Sender as Sender
participant Receiver as Receiver

loop Encrypt and send message
Sender->>TWERO: Send encrypted message to Receiver
TWERO->>DERO: Encrypt message using DERO wallet API
DERO-->>TWERO: Return encrypted message
TWERO->>Twitter: Send encrypted message to Receiver
Twitter-->>Receiver: Deliver message
end

loop Decrypt message
Receiver->>TWERO: Decrypt message using DERO wallet API
TWERO->>DERO: Request decryption of message
DERO-->>TWERO: Return decrypted message
TWERO-->>Receiver: Deliver decrypted message
end

loop Request and confirm payment
Sender->>TWERO: Request payment from Receiver
TWERO->>DERO: Request payment from Receiver's wallet
DERO-->>Receiver: Prompt Receiver to confirm payment
Receiver-->>DERO: Confirm payment
DERO-->>TWERO: Confirm payment
TWERO-->>Sender: Payment received
end

loop Simple send payment
Sender->>TWERO: Request payment from DERO
TWERO->>DERO: Request payment from Sender's wallet
DERO-->>Sender: Prompt Sender to confirm payment
Sender-->>DERO: Confirm payment
DERO-->>TWERO: Confirm payment
TWERO-->>Receiver: Payment received
end

Note right of TWERO: TWERO uses Twitter API and DERO wallet API to facilitate communication and transactions within Twitter platform
Note right of DERO: DERO uses homomorphic encryption to secure messages and transactions
Note right of Sender: Sender can send encrypted messages and request payments with confidence
Note right of Receiver: Receiver can decrypt messages and make payments securely through TWERO
```

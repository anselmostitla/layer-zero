# LayerZero Protocol Workflow

We begin by reviewing the main smart contracts involved in the LayerZero protocol:

---

## 1. `OFT` (Omnichain Fungible Token) Contract

This smart contract extends both the `OFTCore` and `ERC20` contracts. It implements two key functions:

- `_debitFrom()`: Burns tokens from the sender on the source chain.  
- `_creditTo()`: Mints tokens to the recipient on the destination chain.

These two functions are the core of the OFT’s cross-chain token transfer functionality.

---

## 2. `OFTCore` Contract

This contract extends `NonblockingLzApp.sol`. It implements the primary user-facing function of the protocol: `sendFrom()`.

### Function Signature

```solidity
function sendFrom(
    address _from,
    uint16 _dstChainId,
    bytes calldata _toAddress,
    uint _amount,
    address payable _refundAddress,
    address _zroPaymentAddress,
    bytes calldata _adapterParams
)
```

### Conceptual Similarity: `sendFrom()` vs `transferFrom()`

You can think of `sendFrom()` as conceptually similar to `transferFrom()` in ERC20, in that:

- `_from` is the address sending the tokens.
- The destination is represented by:
  - `_dstChainId`: the target chain ID.
  - `_toAddress`: the target address on the destination chain.
- `_amount` is the number of tokens to transfer.

---

### Additional Parameters

- `_refundAddress`: If the user overpays for gas, this address receives the refund.
- `_zroPaymentAddress`: Set to the zero address (`address(0)`) if the user isn't using LayerZero’s native token (ZRO) to pay the messaging fee.

---

### Internal Logic of `sendFrom()`

The `sendFrom()` function internally calls `_send()`, which performs the following actions:

1. **Validates** the `adapterParams`.
2. **Burns tokens** from the sender using `_debitFrom()`.
3. **Encodes a payload** to be sent cross-chain:

```solidity
bytes lzPayload = abi.encodePacked(uint16(PT_SEND), _toAddress, _amount);
```

4. `_lzSend()` Invocation

The `_send()` function concludes by invoking `_lzSend()` with:

- The destination chain ID
- The encoded payload (`lzPayload`)
- Fee-related parameters
- The Ether sent with the transaction (`msg.value`)

---

### 3. `NonblockingLzApp.sol`

This contract extends `LzApp.sol` and overrides the `_blockingLzReceive()` function to make the messaging system **non-blocking**.

> 📌 This ensures that if a message fails on the destination chain, it won’t block other subsequent messages from being delivered.

We’ll revisit this contract after covering `LzApp.sol`.

---

### 4. `LzApp.sol`

This is the **base contract** for all LayerZero-enabled user applications. It provides:

- ✅ Security checks for trusted remote addresses  
- ⚙️ Configuration management (e.g., gas limits, payload size restrictions)  
- 🧩 The core messaging function: `_lzSend()`

---

#### `_lzSend()`

This function validates the destination chain and sends the payload through the LayerZero endpoint using the `send()` method:

```solidity
lzEndpoint.send{value: _nativeFee}(
    _dstChainId,
    trustedRemote,
    _payload,
    _refundAddress,
    _zroPaymentAddress,
    _adapterParams
);
```

---

### 5. `LZEndpointMock.sol`

This is the **mock implementation** of the LayerZero endpoint used for local testing environments.

It contains the `send()` function, which simulates a cross-chain message by directly invoking `receivePayload()` on the **destination** endpoint.

---

#### `receivePayload()`

This function simulates the **arrival** of a message on the destination chain. It:

- Pushes the message into an internal array (e.g., a message queue)
- Emulates delivery by **storing**, not executing, the payload

> ⚠️ **Note:** In the mock version, delivery is **manual**.  
> You must call `receivePayload()` yourself to simulate arrival and processing.  
> There is **no automatic message execution**.

---

## ✅ Summary of Workflow

1. The user calls `sendFrom()` on the **source chain**.
2. The token is **burned** using `_debitFrom()`.
3. A **payload** is created and sent using `_lzSend()`, which interacts with the LayerZero `send()` function.
4. The destination endpoint receives and queues the message via `receivePayload()`.
5. The destination `OFT` contract **mints tokens** using `_creditTo()`.

---





forge install OpenZeppelin/openzeppelin-contracts@v4.7.3


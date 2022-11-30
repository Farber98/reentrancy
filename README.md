# Reentrancy vulnerability

A reentrancy attack occurs when a function makes an external call to another untrusted contract. Then the untrusted contract makes a recursive call back to the original function in an attempt to drain funds. When the contract fails to update its state before sending funds, the attacker can continuously call the withdraw until funds are completely drained.

## Reproduction

### 📜 Involves two smart contracts.

    1. A vulnerable contract with 10 eth.
    2. An untrusted attacker’s contract that has 1 eth.

### 🪜 Steps

    1. Malicious SC stores 1 eth using the deposit function of the vulnerable contract.

    2. Malicious SC calls the withdraw function.

    3. Now withdraw function will verify if it can be executed

        * Does the attacker have enough balance? Yes.

        * Transfers 1 eth to a malicious SC without updating balance

        * Fallback function receives eth on malicious SC and calls withdraw again.

    4. Step 3. repeated until funds are fully drained from vulnerable SC.

## How to prevent it

🚧 All state changes must happen before making external calls.

🔐 Use a mutex modifier.

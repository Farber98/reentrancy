# Reentrancy vulnerability

A reentrancy attack occurs when a function makes an external call to another untrusted contract. Then the untrusted contract makes a recursive call back to the original function in an attempt to drain funds. When the contract fails to update its state before sending funds, the attacker can continuously call the withdraw until funds are completely drained.

## Reproduction

### 📜 Involves two smart contracts.

    1. A vulnerable contract with eth deposited from victims.
    2. A malicious contract where an attacker sends 1 eth to attack.

### 🪜 Steps

    1. Attacker deposits 1 eth to vulnerable sc through malicious sc attack function.

    2. Malicious SC calls the withdraw function to withdraw 1 eth.

    3. Now withdraw function will verify if it can be executed

        * Does the attacker have enough balance? Yes, he deposited 1 eth.

        * Transfers 1 eth to a malicious SC without updating balance.

        * Fallback function receives eth on malicious SC and calls withdraw again before vulnerable sc updates balance.

    4. Repeat from step 3. until funds are fully drained from vulnerable SC.

## How to prevent it

🚧 All state changes must happen before making external calls.

🔐 Use a mutex modifier.

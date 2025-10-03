# KipuBank

## Descripción
KipuBank es un contrato inteligente seguro desarrollado en Solidity que permite a los usuarios depositar y retirar ETH con límites configurables. Implementa prácticas de seguridad como protección contra reentrancy, errores personalizados y el patrón checks-effects-interactions.

## Características
- Depósitos de ETH con límite global (bankCap)
- Retiros con límite máximo por transacción  
- Protección contra ataques de reentrancy
- Seguimiento de estadísticas (total de depósitos/retiros)
- Eventos para tracking de transacciones
- Errores personalizados para mejor eficiencia en gas

## Contrato Desplegado
**Red:** Sepolia Testnet  
**Contract Address:** `0x5138c9cb760d71d9a19ad7b371c64213a51084c1`  
**Etherscan:** https://sepolia.etherscan.io/address/0x5138c9cb760d71d9a19ad7b371c64213a51084c1

## Estructura del Contrato

### Variables de Estado
**Variables de Almacenamiento:**
- `vaults` (mapping) - Almacena los balances de cada usuario
- `totalDeposits` (uint256) - Contador total de depósitos realizados
- `totalWithdraws` (uint256) - Contador total de retiros realizados
- `locked` (bool) - Guardia para protección anti-reentrancy

**Variables Inmutables:**
- `bankCap` (uint256) - Límite global de depósitos del contrato
- `withdrawLimit` (uint256) - Límite máximo por transacción de retiro

### Funciones Principales
**External/Payable:**
- `deposit()` - Permite depositar ETH en la bóveda personal
- `withdraw(uint256 amount)` - Permite retirar ETH de la bóveda personal

**View:**
- `getBalance(address user)` - Devuelve el saldo de un usuario
- `bankBalance()` - Devuelve el balance total del contrato
- `bankCap()` - Devuelve el límite global de depósitos
- `withdrawLimit()` - Devuelve el límite máximo por retiro

**Private:**
- `_addToVault(address user, uint256 amount)` - Función interna para actualizar balances

### Eventos
- `Deposit(address indexed user, uint256 amount)` - Emitido en depósitos exitosos
- `Withdrawal(address indexed user, uint256 amount)` - Emitido en retiros exitosos

### Errores Personalizados
- `ExceedsBankCap(uint256 attempted, uint256 cap)`
- `ExceedsWithdrawLimit(uint256 attempted, uint256 limit)`
- `InsufficientBalance(uint256 available, uint256 requested)`
- `ZeroDeposit()`
- `TransferFailed(address to, uint256 amount)`
- `ReentrancyAttack()`

## Despliegue con Remix

### Prerrequisitos
- Navegador web con MetaMask instalado
- Conexión a la red Sepolia
- ETH de Sepolia en tu wallet

### Pasos para Despliegue
1. Ve a [Remix IDE](https://remix.ethereum.org)
2. Crea un nuevo archivo llamado `KipuBank.sol` y pega el código del contrato
3. Compila el contrato en la pestaña "Solidity Compiler"
4. En la pestaña "Deploy & Run Transactions":
   - Selecciona el entorno "Browser Wallet" (conectado a Sepolia)
   - Selecciona "Sepolia Testnet - MetaMask" en el buscador
   - Ingresa los parámetros del constructor: `_bankCap` y `_withdrawLimit` (en wei)
   - Haz clic en "Transact" y confirma la transacción en MetaMask

### Parámetros del Constructor (Ejemplo)
- `_bankCap`: 10000000000000000000 (10 ETH en wei)
- `_withdrawLimit`: 2000000000000000000 (2 ETH en wei)

## Interacción con el Contrato

### Depósitos
1. En la pestaña "Deployed Contracts" de Remix, selecciona tu contrato desplegado
2. En la función `deposit`, ingresa la cantidad de ETH a depositar en el campo "Value" (en wei o selecciona ETH en el desplegable)
3. Haz clic en "transact" y confirma la transacción

### Retiros
1. En la función `withdraw`, ingresa la cantidad a retirar (en wei) en el parámetro `amount`
2. Haz clic en "transact" y confirma la transacción

### Consultas
- `getBalance(address)`: Ingresa una dirección y haz clic en "call" para ver el saldo
- `bankBalance()`: Haz clic en "call" para ver el balance total del contrato
- `bankCap()` y `withdrawLimit()`: Haz clic en "call" para ver los límites

## Verificación del Código en Etherscan
Link: https://sepolia.etherscan.io/address/0x5138c9cb760d71d9a19ad7b371c64213a51084c1#code
Contract Address: 0x5138c9cb760D71D9a19aD7b371c64213A51084C1 

## Prácticas de Seguridad Implementadas
- ✅ **Checks-Effects-Interactions** - Seguido estrictamente en todas las funciones
- ✅ **Protección contra Reentrancy** - Modificador `noReentrancy` 
- ✅ **Manejo Seguro de Transferencias** - Uso de `call` con verificación
- ✅ **Validación de Límites** - Modificadores `underBankCap` y `withinWithdrawLimit`
- ✅ **Errores Personalizados** - Mejor eficiencia en gas y claridad
- ✅ **Eventos de Tracking** - Para depósitos y retiros exitosos

## Tecnologías Utilizadas
- **Solidity**: 0.8.30
- **Remix IDE**: Para desarrollo y despliegue
- **MetaMask**: Para gestión de wallet
- **Ethereum Testnet**: Sepolia
- **Etherscan**: Para verificación

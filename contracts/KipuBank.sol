// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/// @title KipuBank - Un smart contract seguro para depósitos y retiros de ETH
/// @author Matías Chacón
/// @notice Este contrato permite a los usuarios depositar y retirar ETH con límites definidos
/// @dev Se implemnetan buenas prácticas de seguridad y manejo de errores personalizados

contract KipuBank {
    
    // -----------------
    // VARIABLES
    // -----------------

    /// @notice Límite global de depósitos del banco
    uint256 public immutable bankCap;

    /// @notice Límite máximo por retiro
    uint256 public immutable withdrawLimit;

    /// @notice Saldo de cada usuario
    mapping(address => uint256) private vaults;

    /// @notice Cantidad total de depósitos realizados
    uint256 private totalDeposits;

    /// @notice Cantidad total de retiros realizados
    uint256 private totalWithdraws;

    /// @notice Reentrancy guard (simple)
    bool private locked;

    // -----------------
    // EVENTOS
    // -----------------
    
    /// @notice Evento emitido cuando un usario realiza un depósito
    event Deposit(address indexed user, uint256 amount);

    /// @notice Evento emitido cuando un usuario realiza un retiro
    event Withdrawal(address indexed user, uint256 amount);
    
    // -----------------
    // ERRORES PERSONALIZADOS
    // -----------------

    /// @notice Se lanza cuando el nuevo balance del contrato excede bankCap
    /// @param attempted Balance que se intentó alcanzar
    /// @param cap Límite máximo del banco
    error ExceedsBankCap(uint256 attempted, uint256 cap);

    /// @notice Se lanza cuando el retiro excede withdrawLimit
    /// @param attempted Cantidad solicitada para retirar
    /// @param limit Límite máximo por transacción
    error ExceedsWithdrawLimit(uint256 attempted, uint256 limit);

    /// @notice Se lanza cuando el usuario intenta retirar más ETH que lo que tiene disponible 
    /// @param available Saldo disponible del usuario
    /// @param requested Cantidad solicitada para retirar
    error InsufficientBalance(uint256 available, uint256 requested);

    /// @notice Se lanza si el depósito es 0
    error ZeroDeposit();

    /// @notice Se lanza si la transferencia nativa falla
    /// @param to Dirección a la que se intentó enviar ETH
    /// @param amount Cantidad que se intentó enviar
    error TransferFailed(address to, uint256 amount);

    /// @notice Se lanza si se detecta reentrancy
    /// @dev Usamos un bloqueo simple para prevenir ataques de reentrancy
    error ReentrancyAttack();

    // -----------------
    // MODIFICADORES
    // -----------------

    /// @notice Previene reentrancy usando un bloqueo simple
    modifier noReentrancy() {
        if(locked) {
            revert ReentrancyAttack();
        }
        locked = true;
        _;
        locked = false;
    }

    /// @notice Verifica que el depósito no supere el límite global del banco (bankCap)
    modifier underBankCap(uint256 amount) {
        if(address(this).balance + amount > bankCap) {
            revert ExceedsBankCap(address(this).balance + amount, bankCap);
        }
        _;
    }
    
    /// @notice Verifica que el retiro no supere el límite máximo por transacción
    modifier withinWithdrawLimit(uint256 amount) {
        if(amount > withdrawLimit) {
            revert ExceedsWithdrawLimit(amount, withdrawLimit);
        }
        _;
    }

    // -----------------
    // CONSTRUCTOR
    // -----------------

    /// @notice Constructor para inicializar los límites del banco
    /// @param _bankCap Límite global de depósitos
    /// @param _withdrawLimit Límite máximo por retiro
    constructor(uint256 _bankCap, uint256 _withdrawLimit) {
        bankCap = _bankCap;
        withdrawLimit = _withdrawLimit;
    }

    // -----------------
    // FUNCIONES PÚBLICAS / EXTERNAS
    // -----------------

    // @notice Deposita ETH en la bóveda del remitente
    /// @dev Usa el modificador underBankCap para validar el límite global y noReentrancy
    function deposit() external payable underBankCap(msg.value) noReentrancy {
        if(msg.value == 0) {
            revert ZeroDeposit(); // podemos cambiarlo luego por un error personalizado
        }

        _addToVault(msg.sender, msg.value); // Función interna para manejar el depósito
        totalDeposits++; // Incrementa el contador de depósitos

        emit Deposit(msg.sender, msg.value); // Emite el evento
    }

    /// @notice Retira `amount` ETH de la bóveda del remitente
    /// @dev Sigue checks-effects-interactions y usa noReentrancy
    function withdraw(uint256 amount) external withinWithdrawLimit(amount) noReentrancy {
        // --- CHECKS (validaciones) ---
        if (amount == 0) revert InsufficientBalance(0, 0); // Forzar a usar InsufficientBalance

        uint256 bal = vaults[msg.sender];
        if (bal < amount) revert InsufficientBalance(bal, amount);

        // --- EFFECTS (actualizamos estado antes de la interacción externa) ---
        vaults[msg.sender] = bal - amount;
        totalWithdraws++;

        // --- INTERACTIONS (envío seguro usando call) ---
        (bool sent, ) = msg.sender.call{value: amount}("");
        if (!sent) revert TransferFailed(msg.sender, amount); // Revert si la transferencia falla

        emit Withdrawal(msg.sender, amount); // Emite el evento
    }

    // -----------------
    // FUNCIONES PRIVADAS / VIEWS
    // -----------------

    /// @notice Función privada que actualiza el mapping de bóvedas
    /// @param user Dirección del usuario que deposita
    /// @param amount Cantidad de ETH a depositar
    function _addToVault(address user, uint256 amount) private {
        vaults[user] += amount;
    }

    /// @notice Devuelve el saldo almacenado para `user`
    /// @param user Dirección del usuario para consultar el saldo
    function getBalance(address user) external view returns (uint256) {
        return vaults[user];
    }

    /// @notice Devuelve el balance total retenido por el contrato
    function bankBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
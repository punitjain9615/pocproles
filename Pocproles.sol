// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract POCPRoles is Initializable, AccessControlUpgradeable {
    event ApproverAdded(bytes32 indexed daoId, address indexed account);
    event ApproverRemoved(bytes32 indexed daoId, address indexed account);
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    
    // mapping dao id -> {role_id -> role_data }
    mapping(bytes32 => RoleData) private _approvers;

    function initialize() initializer public {
        __AccessControl_init();
        _setRoleAdmin(PAUSER_ROLE, PAUSER_ROLE);
        _setRoleAdmin(UPGRADER_ROLE, UPGRADER_ROLE);
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(PAUSER_ROLE, _msgSender());
        _grantRole(UPGRADER_ROLE, _msgSender());
    }

    function hasRole(bytes32 role, address account) public view  override returns (bool) {
        return _approvers[role].members[account];
    }

    function _checkRole(bytes32 role) internal view  {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal override view  {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view  override returns (bytes32) {
        return _approvers[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public  override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public  override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public  override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) override internal  {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole)  override internal  {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _approvers[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account)  override internal  {
        if (!hasRole(role, account)) {
            _approvers[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) override internal  {
        if (hasRole(role, account)) {
            _approvers[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
  // For future extensions
  uint256[50] private ______gap;
}

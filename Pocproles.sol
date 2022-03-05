// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract POCPRoles is Initializable, AccessControlUpgradeable {
  event ApproverAdded(bytes32 indexed daoId, address indexed account);
  event ApproverRemoved(bytes32 indexed daoId, address indexed account);
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

  // mapping dao id -> {role_id -> role_data }
  mapping(bytes32 => RoleData) private _approvers;

  function __POCPRoles_init() public initializer {
    __AccessControl_init();
    _addApprover(DEFAULT_ADMIN_ROLE, _msgSender());
    _addApprover(PAUSER_ROLE, _msgSender());
    _addApprover(UPGRADER_ROLE, _msgSender());
  }

  modifier onlyApprover(bytes32 daoUuid, address account) {
    require(isApprover(daoUuid, account), "Not Approver");
    _;
  }

  function isApprover(bytes32 daoUuid, address account) public view returns (bool) {
    return _approvers[daoUuid].members[account];
  }

  function addApprover(bytes32 daoUuid, address account) public onlyApprover(daoUuid, _msgSender()) {
    _addApprover(daoUuid, account);
  }

  function _addApprover(bytes32 daoUuid, address account) internal  {
        if (!isApprover(daoUuid, account)) {
            _approvers[daoUuid].members[account] = true;
            emit RoleGranted(daoUuid, account, _msgSender());
        }
  }
  function removeApprover(bytes32 daoUuid, address account) public onlyApprover(daoUuid, _msgSender()) {
    _removeApprover(daoUuid, account);
  }

  function _removeApprover(bytes32 daoUuid, address account)  internal  {
    if (isApprover(daoUuid, account)) {
        _approvers[daoUuid].members[account] = false;
        emit ApproverRemoved(daoUuid, account);
    }
  }

  function getRoleAdmin(bytes32 daoUuid) public view  override returns (bytes32) {
      return _approvers[daoUuid].adminRole;
  }

  function _setRoleAdmin(bytes32 daoUuid, bytes32 adminRole)  override internal  {
      bytes32 previousAdminRole = getRoleAdmin(daoUuid);
      _approvers[daoUuid].adminRole = adminRole;
      emit RoleAdminChanged(daoUuid, previousAdminRole, adminRole);
  }
  // For future extensions
  uint256[50] private ______gap;
}

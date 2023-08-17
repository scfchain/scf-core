package state

import (
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/log"
)

const (
	WHITELISTED   = "whitelisted"
	WHITELIST_ALL = "whitelistAll"
	BLACKLISTED   = "_blacklisted"
	DISABLED      = "disabled"
	VALIDATORS    = "validators"
)

var (
	slotWhitelistDeployerMapping = map[string]uint64{
		WHITELISTED:   1,
		WHITELIST_ALL: 2,
	}
	slotBlacklistContractMapping = map[string]uint64{
		BLACKLISTED: 1,
		DISABLED:    2,
	}
	slotSCValidatorMapping = map[string]uint64{
		VALIDATORS: 1,
	}
	slotFChainValidatorMapping = map[string]uint64{
		VALIDATORS: 6,
	}
)

// IsWhitelistedDeployer reads the contract storage to check if an address is allow to deploy
func IsWhitelistedDeployer(statedb *StateDB, address common.Address) bool {
	contract := common.HexToAddress(common.WhitelistDeployerSC)
	whitelistAllSlot := slotWhitelistDeployerMapping[WHITELIST_ALL]
	whitelistAll := statedb.GetState(contract, GetLocSimpleVariable(whitelistAllSlot))
	if whitelistAll.Big().Cmp(big.NewInt(1)) == 0 {
		return true
	}

	whitelistedSlot := slotWhitelistDeployerMapping[WHITELISTED]
	valueLoc := GetLocMappingAtKey(address.Hash(), whitelistedSlot)
	whitelisted := statedb.GetState(contract, valueLoc)

	return whitelisted.Big().Cmp(big.NewInt(1)) == 0
}

// IsAddressBlacklisted reads the contract storage to check if an address is blacklisted or not
func IsAddressBlacklisted(statedb *StateDB, blacklistAddr *common.Address, address *common.Address) bool {
	if blacklistAddr == nil || address == nil {
		return false
	}

	contract := *blacklistAddr
	disabledSlot := slotBlacklistContractMapping[DISABLED]
	disabled := statedb.GetState(contract, GetLocSimpleVariable(disabledSlot))
	if disabled.Big().Cmp(big.NewInt(1)) == 0 {
		return false
	}

	blacklistedSlot := slotBlacklistContractMapping[BLACKLISTED]
	valueLoc := GetLocMappingAtKey(address.Hash(), blacklistedSlot)
	blacklisted := statedb.GetState(contract, valueLoc)
	return blacklisted.Big().Cmp(big.NewInt(1)) == 0
}

func GetSCValidators(statedb *StateDB) []common.Address {
	slot := slotSCValidatorMapping[VALIDATORS]
	slotHash := common.BigToHash(new(big.Int).SetUint64(slot))
	arrLength := statedb.GetState(common.HexToAddress(common.ValidatorSC), slotHash)
	keys := []common.Hash{}
	for i := uint64(0); i < arrLength.Big().Uint64(); i++ {
		key := GetLocDynamicArrAtElement(slotHash, i, 1)
		keys = append(keys, key)
	}
	rets := []common.Address{}
	for _, key := range keys {
		ret := statedb.GetState(common.HexToAddress(common.ValidatorSC), key)
		rets = append(rets, common.HexToAddress(ret.Hex()))
	}
	return rets
}

func GetFenixValidators(statedb *StateDB, fchainValidatorContract *common.Address) []common.Address {
	if fchainValidatorContract == nil {
		log.Crit("Cannot get FChain Validator contract")
		return GetSCValidators(statedb)
	}

	slot := slotFChainValidatorMapping[VALIDATORS]
	slotHash := common.BigToHash(new(big.Int).SetUint64(slot))
	arrLength := statedb.GetState(*fchainValidatorContract, slotHash)
	keys := []common.Hash{}
	for i := uint64(0); i < arrLength.Big().Uint64(); i++ {
		key := GetLocDynamicArrAtElement(slotHash, i, 1)
		keys = append(keys, key)
	}
	rets := []common.Address{}
	for _, key := range keys {
		ret := statedb.GetState(*fchainValidatorContract, key)
		rets = append(rets, common.HexToAddress(ret.Hex()))
	}
	return rets
}

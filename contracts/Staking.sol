// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import './IERC20.sol';

contract Staking {
    uint256 rewardPool;
    uint256 stakedBalance;
    address tokenAdress;
    uint256 stakingPeriod;
    uint256 REWARD_RATE;

    mapping(address=>uint256) staked;
    mapping(address=>uint256) reward;

    event Staked(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    error ZERO_ACCOUNT_DETECTED();
    error NO_CONTRIBUTION();
    error ZERO_STAKING_DETECTED();
    error CLAIM_FAILED();
    error STAKING_FAILED();
    error UNSTAKING_FAILED();
    error ALREADY_STAKED();
    error STAKING_PERIOD_IN_THE_PAST();
    error STAKING_PERIOD_STILL_ON();

    constructor(address _tokenAddress, uint256 _stakingPeriod, uint _rewardPool){
        if (_stakingPeriod < block.timestamp){revert STAKING_PERIOD_IN_THE_PAST();}
        tokenAdress= _tokenAddress;
        stakingPeriod= _stakingPeriod;
        rewardPool= _rewardPool;
    }

    function stake(uint256 _amount) external returns(bool){
        if(msg.sender == address(0)){revert ZERO_ACCOUNT_DETECTED();}
        if(staked[msg.sender]!=0){revert ALREADY_STAKED();}
        if(_amount <= 0){revert ZERO_STAKING_DETECTED();}
        if(!IERC20(tokenAdress).transferFrom(msg.sender, address(this), _amount)){revert STAKING_FAILED();}
        stakedBalance= stakedBalance + _amount;
        staked[msg.sender]= staked[msg.sender] + _amount;

        return true;
    }

    function unstake() external returns(bool){
        if (block.timestamp < stakingPeriod){revert STAKING_PERIOD_STILL_ON();}

        uint256 _stakedAmount = staked[msg.sender];
        if (_stakedAmount==0){revert NO_CONTRIBUTION();}

        staked[msg.sender] = staked[msg.sender] - _stakedAmount;
        stakedBalance= stakedBalance - _stakedAmount;
        
        if (!IERC20(tokenAdress).transfer(msg.sender, _stakedAmount)){revert UNSTAKING_FAILED();}
        return true;
    }


    function claimReward() external returns(bool){
        if (block.timestamp < stakingPeriod){revert STAKING_PERIOD_STILL_ON();}
        
        uint256 _stakedAmount = staked[msg.sender];
        if (_stakedAmount==0){revert NO_CONTRIBUTION();}

        uint256 calculatedReward= calculateReward(msg.sender);
        if (!IERC20(tokenAdress).transfer(msg.sender, calculatedReward)){revert CLAIM_FAILED();}

        return true;
    }

    function checkUserStakedBalance(address _user) external view returns(uint256){
        return staked[_user];
    }

    function totalStakedBalance() external view returns(uint256){
        return stakedBalance;
    }

    function calculateReward(address _user) private view returns(uint){
        uint256 Reward = (rewardPool * staked[_user]) / stakedBalance;
        return Reward;
    }
}
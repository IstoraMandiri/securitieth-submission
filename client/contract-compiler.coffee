@web3 = new Web3()
web3.setProvider(new web3.providers.HttpProvider('http://localhost:8101'))
web3.eth.defaultAccount = web3.eth.accounts[0]

@Contracts = @Contracts || {}

Meteor.startup ->
    for key, val of web3.eth.compile.solidity(contractsSource)
        Contracts[key] = web3.eth.contract(val.info.abiDefinition)
        Contracts[key].code = val.code

contractsSource = """

contract corpAct{
    function execute(address sender, uint amount, uint extraData){}
}

contract securityRegistry{
    mapping(uint=>address) public registry;
    uint count;
    function add(){
        registry[count] = msg.sender;
        count++;
    }
}


contract security{

    function security(uint quant,address registry){
    securityRegistry(registry).add();
    balances[msg.sender][0] = quant;
    issuer = msg.sender;
    }

    function sendCoin(address recipient, uint amount, uint state) returns (bool successful){
        if (balances[msg.sender][state] < amount) return false;
        balances[msg.sender][state] -= amount;
        balances[recipient][state] += amount;
        return true;
    }
    function runCA(uint amount, uint state, uint extra){
        if (balances[msg.sender][state] < amount) return;
        corpAct(cAContracts[state]).execute(msg.sender, amount, extra);
    }

    //Issuer can add a corporate action contract
    function addCorporateAction(address contr){
        if (issuer !=msg.sender) return;
        cAContracts[currentState] = contr;
        currentState++;
    }

    //can only called by corporate action contracts but can freely amend any balances
    function admin(uint corpAct, address account, int amount, uint state){
        if(msg.sender != address(cAContracts[corpAct])) return;

        var bal = int(balances[account][state]) + amount;
        balances[account][state] = uint(bal);
        return;

    }
    address issuer;
    uint currentState;
    mapping(uint => address) cAContracts;

    mapping(address =>mapping(uint=>uint)) public balances;
}



//contract is funded with ether to pay the coupon
contract coupon is corpAct{
    function coupon(address parent, uint rate, uint ca){
        parentSecurity = parent;
        couponRate = rate;
        corpAct = ca;
    }
    address public parentSecurity;
    uint public couponRate;
    uint public corpAct;

    function execute(address sender, uint amount, uint extraData){
        if (msg.sender != parentSecurity) return;
        sender.send(amount*couponRate);
        security(msg.sender).admin(corpAct,sender,-int(amount),corpAct);
        security(msg.sender).admin(corpAct,sender,int(amount),corpAct+1);
    }

}

contract dividend is corpAct{
    function dividend(address parent, uint rate, uint ca){
        parentSecurity = parent;
        dividendRate = rate;
        corpAct = ca;
    }
    address public parentSecurity;
    uint public dividendRate;
    uint public corpAct;

    function execute(address sender, uint amount, uint extraData){
        if (msg.sender != parentSecurity) return;
        sender.send(amount*dividendRate);
        security(msg.sender).admin(corpAct,sender,-int(amount),corpAct);
        security(msg.sender).admin(corpAct,sender,int(amount),corpAct+1);
    }

}

//Voting contract tallies votes of share holders
contract proxyVote is corpAct{
    function proxyVote(address parent, uint ca){
        parentSecurity = parent;
        corpAct = ca;
    }
    address public parentSecurity;
    uint public corpAct;
    mapping(uint=>uint) votes;
    //this records the votes and moves the shares to a new state.
    function execute(address sender, uint amount, uint extraData){
        if (msg.sender != parentSecurity) return;
        votes[extraData] += amount;
        security(msg.sender).admin(corpAct,sender,-int(amount),corpAct);
        security(msg.sender).admin(corpAct,sender,int(amount),corpAct+1);
    }

}
//contract i sfunded with ether to pay the redemption
contract redemption is corpAct{
    function redemption(address parent, uint rate, uint ca){
        parentSecurity = parent;
        redemptionRate = rate;
        corpAct = ca;
    }
    address public parentSecurity;
    uint public redemptionRate;
    uint public corpAct;

    function execute(address sender, uint amount, uint extraData){
        if (msg.sender != parentSecurity) return;
        sender.send(amount*redemptionRate);
        security(msg.sender).admin(corpAct,sender,-int(amount),corpAct);
    }

}
//Credits users with a certain number of new shares in a new company.
contract spinOff is corpAct{
    function spinOff(address parent, address newShares, uint rate, uint ca){
        parentSecurity = parent;
        ratio = rate;
        corpAct = ca;
        spinoff = security(newShares);
    }
    address public parentSecurity;
    uint public ratio;
    uint public corpAct;
    security spinoff;
    //calls the security contracts and removes the old shares and adds the new shares
    function execute(address sender, uint amount, uint extraData){
        if (msg.sender != parentSecurity) return;
        spinoff.admin(0,sender,int(amount*ratio),1);
        security(msg.sender).admin(corpAct,sender,-int(amount),corpAct);
        security(msg.sender).admin(corpAct,sender,int(amount),corpAct+1);
    }

}

//Stock splits increase the number of shares in existence (ie for evry 1 share you own you get three new shares)
contract stockSplit is corpAct{
    function stockSplit(address parent, uint rate, uint ca){
        parentSecurity = parent;
        ratio = rate;
        corpAct = ca;
    }
    address public parentSecurity;
    uint public ratio;
    uint public corpAct;
    //calls the security contracts and removes the old shares and adds the new shares
    function execute(address sender, uint amount, uint extraData){
        if (msg.sender != parentSecurity) return;
        security(msg.sender).admin(corpAct,sender,-int(amount),corpAct);
        security(msg.sender).admin(corpAct,sender,int(3*amount),corpAct+1);
    }

}
"""
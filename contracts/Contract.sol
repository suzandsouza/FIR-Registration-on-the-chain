// SPDX-License-Identifier: MI
pragma solidity ^0.8.9;

contract MyContract {
    //variables
    address public officer;
    address public owner;
    uint256 public nextId;  //for tracking
    uint256 [] public pendingApprovals;
    uint256 [] public pendingResolutions;
    uint256[] public resolvedCases;

    constructor(address _officer) {
        owner=msg.sender;
        officer=_officer;
        nextId=1;
    }
    modifier onlyOwner()
    {
        require(msg.sender==owner,
            "You are not the owner of this smart contract");_;
            //underscore is used for identifying where we should add the 
            //code of the function being modified

    }
    modifier onlyOfficer()
    {
        require(msg.sender==officer,
            "You are not the officer of this smart contract");_;
            //underscore is used for identifying where we should add the 
            //code of the function being modified
            
    }
    struct complaint{
        uint256 id;
        address complaintRegisteredBy;
        string title;
        string description;
        string approvalRemark;  //when police will mark the complaint as not spam and balid
        string resolutionRemark;
        bool isApproved;
        bool isResolved;
        bool exists;
    }
    mapping(uint256=>complaint) public Complaints;

    event complaintFiled(
        uint256 id,address complaintRegisteredBy,
        string title
    );
    function fileComplaint(string memory _title,string memory _description) public{
        complaint storage newComplaint=Complaints[nextId];
        newComplaint.id=nextId;
        newComplaint.title=_title;
        newComplaint.description=_description;
        newComplaint.approvalRemark="Pending approval";
        newComplaint.resolutionRemark="Pending resolution";
        newComplaint.isApproved=false;
        newComplaint.isResolved=false;
        newComplaint.exists=true;   //because the compalint is just filed
        emit complaintFiled(nextId,msg.sender,_title);
        nextId++;
    }

    // complaint approval
    function approvedComplaint(uint256 _id,string memory _approvalRemark) public onlyOfficer{
        require(Complaints[_id].exists==true,"This complaint id doesn't exist");
        require(Complaints[_id].isApproved==false,"Complaint is already approved");
        Complaints[_id].isApproved=true;
        Complaints[_id].approvalRemark=_approvalRemark;
    }

    function declineComplaint(uint256 _id,string memory _approvalRemark) public onlyOfficer{
        require(
            Complaints[_id].exists == true,
            "This complaint id does not exist"
        );
        require(
            Complaints[_id].isApproved == false,
            "Complaint is already approved"
        );
        Complaints[_id].exists = false;
        Complaints[_id].approvalRemark = string.concat("This complaint is rejected. Reason: ",
_approvalRemark
        );
    }

    function resolveComplaint(uint256 _id,string memory _resolutionRemark)
    public onlyOfficer{
            require(Complaints[_id].exists==true,
            "This complaint id does not exist");
            
            require(Complaints[_id].isApproved==true,
            "Complaint is already approved");
            require(Complaints[_id].isResolved==false,
            "Complaint is already resolbed");

            Complaints[_id].isResolved=true;
            Complaints[_id].resolutionRemark=_resolutionRemark;


    }

    function calcPendingApprovalIds() public{
        delete pendingApprovals;
        for(uint256 i=1;i<nextId;i++){
            if(Complaints[i].isApproved==false && Complaints[i].exists==true)
            {
                pendingApprovals.push(Complaints[i].id);
            }
        }
    }


    function calcPendingResolutionIds() public{
        delete pendingResolutions;
        for(uint256 i=1;i<nextId;i++){
            if(Complaints[i].isResolved==false && Complaints[i].isApproved==true && Complaints[i].exists==true)
            {
                pendingResolutions.push(Complaints[i].id);
            }
        }
    }

    
    function calcResolbedIds() public{
        delete resolvedCases;
        for(uint256 i=1;i<nextId;i++){
            if(Complaints[i].isResolved==true)
            {
               resolvedCases.push(Complaints[i].id);
            }
        }
    }

    function setOfficerAddress(address _officer)public onlyOwner{
        owner=_officer;
        
    }
}
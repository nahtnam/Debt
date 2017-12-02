pragma solidity ^0.4.18;

contract Debt {
  uint debtsCount; // total number of debts for index 
  bytes32[] peopleList; // list of names
  mapping (bytes32 => uint[]) debtsBacking; // mapping of arrays of all debts that belong to people
  mapping (bytes32 => Person) people; // mapping of all people
  mapping (uint => Debts) debts; // mapping of debts

  struct Person {
    bytes32 name; // persons name
    int totalOwed; // the total they owe
    uint[] debtsIds; // a list of all debts
    bool exists; // always set to true unless user is deleted
  }

  struct Debts {
    int amount; // amount in cents
    bytes32 description; // what the item is
    bytes32 person; // the name of the owner
    bool paid; // if the debt has been paid
    bool exists;
  }

  function Debt() public {
    // constructor
  }

  function addPerson(bytes32 name) public {
    require (!people[name].exists); // make sure user doesn't already exist
    // create a new person
    people[name] = Person({
      name: name,
      totalOwed: 0,
      debtsIds: debtsBacking[name],
      exists: true
    });
    // add the name to the list of people
    peopleList.push(name);
  }

  function addDebt(bytes32 name, int amount, bytes32 description) public {
    var person = getPersonReference(name); // get the person
    person.totalOwed += amount; // update the amount owed
    debts[debtsCount] = Debts({ // create a debt
      amount: amount,
      description: description,
      person: name,
      paid: false,
      exists: true
    });
    debtsCount++; // increase the debtsCount
    person.debtsIds.push(debtsCount); // add the debt to the list of debts for the person
  }

  function getPersonReference(bytes32 name) internal view returns (Person storage) {
    var person = people[name]; // get the person
    require(person.exists); // make sure they exist
    return (person); // return the person
  }

  function getDebtsReference(uint id) internal view returns (Debts storage) {
    var debt = debts[id]; // get the person
    require(debt.exists); // make sure they exist
    return (debt); // return the person
  }

  function getPeople() public view returns (bytes32[]) {
    return (peopleList); // return a list of all the people
  }

  function getPerson(bytes32 name) public view returns (bytes32, int, uint[]) {
    var person = getPersonReference(name); // get the person
    return (person.name, person.totalOwed, person.debtsIds); // return the person
  }

  function getDebt(uint id) public view returns (int, bytes32, bytes32, bool) {
    require(id > 0 && id <= debtsCount); // make sure the debt actually exists
    id -= 1; // decrement the counter by one - you can do it the other way around but this uses less gas if the debt doesnt exist
    return (debts[id].amount, debts[id].description, debts[id].person, debts[id].paid); // return the debt
  }

  function payDebt(uint id) public {
    require(id > 0 && id <= debtsCount); // make sure the debt exists
    id -= 1; // decrement the id
    var debt = debts[id];
    debt.paid = true; // mark the debt as paid
    var person = getPersonReference(debt.person);
    person.totalOwed -= debt.amount; // subtract the amount from the totalOwed
  }
}

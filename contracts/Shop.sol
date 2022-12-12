// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
 * @title Shop
 * @dev this contract gives possibility to buy some product from shop if the shop has
 * the owner can add and remove product, define product price, get users data, withdraw the funds.
 * Publicly available opportunities such as buy product, check product being, get product price.
 */
contract Shop {
    address owner;

    struct User {
        string name;
        string surName;
        string[] product;
    }

    mapping(string => uint) productPrice;
    mapping(string => uint) productQuantity;
    mapping(address => User) userData;

    event Buy(
        string indexed name,
        string indexed surName,
        string indexed product
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner!");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev via this function users can buy product if it is.
     * Function save users data for shop
     * @param _name user name to add to the list
     * @param _surname user surename to add to the list
     * @param _product to understand which product users want
     */
    function buy(
        string memory _name,
        string memory _surname,
        string memory _product
    ) external payable {
        // Check if the parameters are correct
        require(
            bytes(_name).length == 0 ||
                bytes(_surname).length == 0 ||
                bytes(_product).length == 0,
            "Incorrect argument(s)!"
        );
        // Check if there is a product
        require(productPrice[_product] != 0, "There is no such product!");
        // Check if user has enough funds to buy product
        require(
            msg.value >= productPrice[_product],
            "Not enough funds to buy the product"
        );

        if (bytes(userData[msg.sender].name).length == 0) {
            userData[msg.sender].name = _name;
            userData[msg.sender].surName = _surname;
        }
        productQuantity[_product]--;
        userData[msg.sender].product.push(_product);

        emit Buy(_name, _surname, _product);
    }

    /**
     * @dev add product to list
     * @param _product to understand which product
     */
    function addProduct(string memory _product) external onlyOwner {
        productQuantity[_product]++;
    }

    /**
     * @dev remove product from list
     * @param _product to understand which product
     */
    function removeProduct(string memory _product) external onlyOwner {
        delete productQuantity[_product];
    }

    /**
     * @dev to define product price
     * @param _product to understand which product
     */
    function defineProductPrice(
        string memory _product,
        uint _amount
    ) external onlyOwner {
        productPrice[_product] = _amount;
    }

    /**
     * @dev to get information about user
     * @param _address to find user data via address
     */
    function getUserData(
        address _address
    ) external view onlyOwner returns (User memory) {
        return userData[_address];
    }

    /**
     * @dev to check if there is a product
     * @param _product to uderstand which product
     */
    function checkProductBeing(
        string memory _product
    ) external view returns (uint) {
        return productQuantity[_product];
    }

    /**
     * @dev to get product price if it is
     * @param _product to uderstand which product
     */
    function getProductPrice(
        string memory _product
    ) external view returns (uint) {
        require(productPrice[_product] != 0, "There is not such product");
        return productPrice[_product];
    }

    /**
     * @dev to withdraw the funds for owner
     */
    function withdraw() external payable onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}

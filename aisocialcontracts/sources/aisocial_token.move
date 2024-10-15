module aisocial_token::aisocial {
    use std::string;
    use std::signer;
    use aptos_framework::coin;
    use aptos_framework::account;

    struct AISOCIAL has key {}

    const INITIAL_SUPPLY: u64 = 1000000000; // 1 billion tokens

    fun init_module(sender: &signer) {
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<AISOCIAL>(
            sender,
            string::utf8(b"AISOCIAL"),
            string::utf8(b"AISC"),
            6, // decimals
            true, // monitor_supply
        );

        // Mint initial supply to the deployer's account
        let coins = coin::mint<AISOCIAL>(INITIAL_SUPPLY, &mint_cap);
        coin::deposit(signer::address_of(sender), coins);

        // Move the capabilities to the resource account
        account::create_resource_account(sender, b"aisocial_resource");
        let resource_signer = account::create_signer_with_capability(
            &account::create_resource_address(signer::address_of(sender), b"aisocial_resource")
        );
        move_to(&resource_signer, burn_cap);
        move_to(&resource_signer, freeze_cap);
        move_to(&resource_signer, mint_cap);
    }

    public entry fun mint(account: &signer, amount: u64) acquires MintCapability {
        let mint_cap = borrow_global<coin::MintCapability<AISOCIAL>>(
            account::create_resource_address(signer::address_of(account), b"aisocial_resource")
        );
        let coins = coin::mint<AISOCIAL>(amount, mint_cap);
        coin::deposit(signer::address_of(account), coins);
    }

    public entry fun transfer(from: &signer, to: address, amount: u64) {
        coin::transfer<AISOCIAL>(from, to, amount);
    }

    #[test_only]
    public fun init_for_test(sender: &signer) {
        init_module(sender);
    }
}
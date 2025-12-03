# DBChain Ruby Client

The official Ruby client library for [DBChain](https://github.com/yzhanginwa/dbchain), a blockchain-based relational database that enables developers to build blockchain applications using familiar database concepts.

[![Gem Version](https://badge.fury.io/rb/dbchain_client.svg)](https://badge.fury.io/rb/dbchain_client)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- 🔐 **Cryptography**: ECDSA signing/verification using secp256k1, AES-256-CBC encryption
- 🔑 **Key Management**: BIP39 mnemonic generation, BIP44 hierarchical deterministic keys, password-protected key storage
- 💾 **Data Operations**: Insert, query, and retrieve data from DBChain tables
- 🔍 **Fluent Query API**: Chainable query builder for complex data retrieval
- 🔒 **Secure Storage**: KeyEscrow system with recovery phrase support
- ⛓️ **Blockchain Integration**: Transaction signing, broadcasting, and account management

## Requirements

* Ruby 2.7+

The current implementation is tested under Ruby 2.7.4 and 3.0.2.

## Installation

Install the gem:

```bash
gem install dbchain_client
```

Or add it to your Gemfile:

```ruby
gem 'dbchain_client'
```

Then run:

```bash
bundle install
```

## Quick Start

### Generate a New Key Pair

```ruby
require 'dbchain_client'

# Generate a random mnemonic phrase (24 words)
mnemonic = DbchainClient::Mnemonics.generate_mnemonic

# Derive master key from mnemonic
master_key = DbchainClient::Mnemonics.mnemonic_to_master_key(mnemonic)

# Generate Cosmos-compatible key pair (m/44'/118'/0'/0/0)
key_pair = DbchainClient::Mnemonics.master_key_to_cosmos_key_pair(master_key)

# Get your address
address = DbchainClient::Mnemonics.public_key_to_address(key_pair[:public_key])
puts "Your address: #{address}"
puts "Your private key: #{key_pair[:private_key]}"
```

### Secure Key Storage

```ruby
# Initialize KeyEscrow and KeyStore
escrow = DbchainClient::KeyEscrow.instance
key_store = DbchainClient::KeyStore.new  # Use your own implementation in production

# Create and save a new private key with password protection
username = "alice"
password = "secure_password"
escrow.create_and_save_private_key_with_password(username, password, key_store)

# Load the private key later
private_key = escrow.load_private_key_with_password(username, password, key_store)

# Reset password using recovery phrase
escrow.reset_password_from_recovery_phrase(username, recovery_phrase, new_password, key_store)
```

### Writing Data

```ruby
# Initialize writer
base_url = "https://your-dbchain-node.com"
chain_id = "dbchain"
private_key_hex = "your_private_key_hex"

writer = DbchainClient::Writer.new(base_url, chain_id, private_key_hex)

# Insert a row into a table
app_code = "your_app_code"
table_name = "users"
fields = {
  name: "Alice",
  email: "alice@example.com",
  age: 30
}

response = writer.insert_row(app_code, table_name, fields)
puts "Transaction hash: #{response}"

# Send tokens
to_address = "dbchain1recipient..."
amount = 1000  # in smallest denomination
writer.send_token(to_address, amount)
```

### Reading Data

```ruby
# Initialize reader
reader = DbchainClient::Reader.new(base_url, private_key_hex)

# Get a specific row by ID
row = reader.get_row(app_code, table_name, row_id)
puts row
```

### Querying with Fluent API

```ruby
# Initialize querier
querier = DbchainClient::Querier.new(base_url, private_key_hex)

# Build and execute a query
result = querier
  .set_app_code(app_code)
  .table("users")
  .select("name", "email")
  .equal("age", 30)
  .find_first
  .run

puts result

# More complex queries
result = querier
  .set_app_code(app_code)
  .table("products")
  .where("price", 100, ">")
  .own  # Filter to current user's records
  .run

# Find by ID
result = querier
  .set_app_code(app_code)
  .table("orders")
  .find(order_id)
  .run
```

## API Reference

### Core Components

#### `DbchainClient::Mnemonics`
Static utility class for BIP39 mnemonic and key derivation operations.

- `generate_mnemonic(strength_bits = 256)` - Generate random mnemonic phrase
- `mnemonic_to_master_key(mnemonic)` - Convert mnemonic to master key
- `master_key_to_cosmos_key_pair(master_key)` - Derive Cosmos key pair
- `public_key_to_address(pub_key)` - Convert public key to Bech32 address

#### `DbchainClient::KeyEscrow`
Singleton class for secure key storage and recovery.

- `create_and_save_private_key_with_password(username, password, key_store_obj)`
- `load_private_key_with_password(username, password, key_store_obj)`
- `save_private_key_with_recovery_phrase(username, recovery_phrase, private_key, key_store_obj)`
- `load_private_key_by_recovery_phrase(username, recovery_phrase, key_store_obj)`
- `reset_password_from_recovery_phrase(username, recovery_phrase, new_password, key_store_obj)`
- `reset_password_from_old(username, old_password, new_password, key_store_obj)`

#### `DbchainClient::Writer`
High-level API for writing data to DBChain.

- `new(base_url, chain_id, private_key_hex)` - Initialize writer
- `insert_row(app_code, table_name, fields)` - Insert data into table
- `send_token(to_address, amount)` - Transfer tokens

#### `DbchainClient::Reader`
High-level API for reading data from DBChain.

- `new(base_url, private_key_hex)` - Initialize reader
- `get_row(app_code, table_name, id)` - Fetch specific row
- `querier(app_code, query_hash)` - Execute custom query
- `generate_access_code(time)` - Create authenticated access code

#### `DbchainClient::Querier`
Fluent query builder for complex data retrieval.

- `set_app_code(app_code)` - Set target application
- `table(table_name)` - Select table
- `find(id)` - Query by ID
- `find_first()` / `find_last()` - Get first/last record
- `select(*fields)` - Select specific fields
- `where(field_name, value, operator)` - Add WHERE condition
- `equal(field_name, value)` - Equality condition helper
- `own()` - Filter to current user's records
- `run()` - Execute the query

#### `DbchainClient::AESCrypt`
AES-256-CBC encryption utilities.

- `encrypt(password, clear_data)` - Encrypt data with password
- `decrypt(password, secret_data_with_iv)` - Decrypt encrypted data

#### `DbchainClient::PrivateKey`
ECDSA private key operations using secp256k1.

- `new(private_key_hex)` - Create from hex string
- `public_key()` - Derive public key
- `sign(message)` - Sign message

#### `DbchainClient::PublicKey`
Public key representation and operations.

- `public_key_hex()` - Hex representation
- `to_raw()` - Raw bytes
- `address()` - Convert to Cosmos address
- `verify(message, signature)` - Verify signature

## Configuration

When initializing the client components, you'll need:

- **base_url**: The URL of your DBChain node (e.g., `https://your-node.com`)
- **chain_id**: The chain identifier (typically `"dbchain"`)
- **private_key_hex**: Your private key in hexadecimal format
- **app_code**: Your application code registered on DBChain

## Development

### Running Tests

```bash
rake test
```

### Test Files

- `test_mnemonics.rb` - Mnemonic and key derivation tests
- `test_key_escrow.rb` - Key storage and recovery tests
- `test_reader.rb` - Data reading tests
- `test_writer.rb` - Data writing tests
- `test_signature.rb` - Signing and verification tests
- `test_queier.rb` - Query builder tests
- `test_aes.rb` - Encryption tests

## Security Notes

- **KeyStore Implementation**: The included `DbchainClient::KeyStore` is a simple in-memory implementation for testing. **You must implement your own persistent storage** for production use (database, encrypted files, etc.)
- **Private Key Protection**: Never commit private keys to version control. Use environment variables or secure key management systems.
- **Recovery Phrases**: Store mnemonic phrases securely offline. They provide full access to your keys.

## Dependencies

- `bitcoin-secp256k1` (~> 0.5.2) - ECDSA cryptography
- `bitcoin-ruby` (~> 0.0.20) - Bitcoin/blockchain utilities
- `base58-alphabets` (1.0.0) - Base58 encoding/decoding

## License

MIT License - see LICENSE file for details

## Links

- [DBChain Documentation](https://github.com/yzhanginwa/dbchain)
- [GitHub Repository](https://github.com/dbchaincloud/ruby-client)
- [Report Issues](https://github.com/dbchaincloud/ruby-client/issues)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

Ethan Zhang

## Version

Current version: 0.8.0

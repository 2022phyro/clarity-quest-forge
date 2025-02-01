import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensures player can initialize their profile",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("quest-forge", "initialize-player", [], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    assertEquals(block.receipts[0].result, '(ok true)');
  },
});

Clarinet.test({
  name: "Can create and complete quests",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("quest-forge", "initialize-player", [], wallet_1.address),
      Tx.contractCall("quest-forge", "create-quest", 
        [types.ascii("My First Quest"), types.uint(1)], 
        wallet_1.address
      )
    ]);
    
    assertEquals(block.receipts.length, 2);
    assertEquals(block.receipts[1].result, '(ok u0)');
    
    block = chain.mineBlock([
      Tx.contractCall("quest-forge", "complete-quest", 
        [types.uint(0)],
        wallet_1.address
      )
    ]);
    
    assertEquals(block.receipts[0].result, '(ok true)');
  },
});

<script>
  import { onMount, beforeUpdate, afterUpdate } from "svelte"
  import { get } from "svelte/store"
  import { balance, login, logout, verifyConnectionAndAgent } from "../../auth"
  import { isAuthenticated, accountId, principalId, ledgerBalance, bc2305Actor } from "../../stores"
  import { getFormattedToken, getLedgerBalance } from "../../lib"
  import ConnectButton from "./ConnectButton.svelte"

  // console.log("Header -> isAuthenticated:", $isAuthenticated)
  $: message = $isAuthenticated
    ? "You are connected"
    : "You are not logged in. Please sign in to authenticate yourself."
  $: loggedInClass = $isAuthenticated ? "logged-in" : ""
  $: ourAccountID = $accountId ? $accountId : "___"
  $: ourPrincipalID = $principalId ? $principalId : "Anonymous"

  async function getBalance(symbol) {
    let response = await balance(symbol)

    if (response) {
      return response.amount
    }
  }

  let icpBalancePromise = getBalance("ICP")
  // Let's fetch the user's ledger balance as well while we're at it.
  let ledgerBalancePromise = $isAuthenticated ? getLedgerBalance(get(bc2305Actor)) : null;
  // ledgerBalance.update(() => tokens ? tokens : 0)

  onMount(async () => {
    console.log("Header -> onMount")
    const res = await verifyConnectionAndAgent()
    // console.log("Header -> verifyConnectionAndAgent -> res", res, "isAuthenticated", $isAuthenticated)
  })

  beforeUpdate(() => {
    console.log("Header -> beforeUpdate - isAuthenticated", $isAuthenticated)
    icpBalancePromise = getBalance("ICP");
    ledgerBalancePromise = $isAuthenticated ? getLedgerBalance(get(bc2305Actor)) : null;
  })

  afterUpdate(() => {
    // console.log("Header -> afterUpdate - isAuthenticated", $isAuthenticated)
  })
</script>

<!-- {#if $isAuthenticated} -->
<div class="account-details {loggedInClass}">
  <ul>
    <li>
      <span>&nbsp;</span>
      <pre><code>{message}</code></pre>
    </li>
    <!-- <li>
      <span>Account ID</span>
      <pre><code>{ourAccountID}</code></pre>
    </li> -->
    <li>
      <span>Principal ID</span>
      <pre><code>{ourPrincipalID}</code></pre>
    </li>
    <li>
      <span>ICP Balance</span>
      <pre><code>{#await icpBalancePromise}___{:then icpAmount}{(icpAmount) ? icpAmount : "0"}{:catch error}___{/await}</code></pre>
    </li>
    <li>
      <span>MOC Tokens</span>
      <pre><code>{#await ledgerBalancePromise}___{:then tokens}{getFormattedToken(tokens)}{:catch error}___{/await}</code></pre>
      <!-- <pre><code>{$ledgerBalance}</code></pre> -->
    </li>
  </ul>
</div>
<!-- {/if} -->

<div class="auth-section">
  <ConnectButton />
</div>

<style>
  .account-details {
    background: rgb(67, 65, 65);
    color: #aaaea4;
    font-size: 1em;
    text-align: left;
    border-radius: 10px;
    padding: 10px;
  }
  .account-details ul {
    list-style: none;
    padding: 5px;
    margin: 1px;
  }
  .account-details ul li {
    list-style: none;
    display: inline-flex;
    align-items: center;
    flex-direction: row;
    flex-wrap: wrap;
    align-content: center;
    justify-content: space-evenly;
  }
  .account-details ul li span {
    display: inline-block;
    margin: auto 15px;
  }
  .account-details.logged-in {
    background-color: #1d3336;
  }
  .account-details ul li:last-child {
    margin-right: 25px;
  }

  .auth-section {
    background: rgb(67, 65, 65);
    color: #aaaea4;
    font-size: 1em;
    text-align: left;
    background-color: #4c4a4a;
    border-radius: 10px;
    border: none;
    padding: 10px;
    margin-right: 0px;
  }
</style>

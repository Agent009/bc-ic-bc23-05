<script>
  import { Principal } from "@dfinity/principal";
  import { onMount, beforeUpdate, afterUpdate } from "svelte"
  import {isAuthenticated, accountId, principal, authSessionData, bc2305Actor, bc2305CanisterId} from "../stores"
  import { decodeUtf8, getSystemParams, getFormattedToken, getLedgerBalance } from "../lib.js"
  import mot from "../assets/mot.png"
  import dfinityLogo from "../assets/dfinity.svg"
  import { get } from "svelte/store"

  //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
  //  REGION:   DEFINITIONS   ----------   ----------   ----------   ----------   ----------   ----------
  //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

  // Grab the staken tokens payload
  let getLedgerBalancePromise = getLedgerBalance(get(daoActor))

  //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
  //  REGION:      GETTING    MODIFIABLE      DATA      ----------   ----------   ----------   ----------
  //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

  //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
  //  REGION:      SVELTE      LIFECYCLE      HOOKS     ----------   ----------   ----------   ----------
  //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

  onMount(async () => {
    // console.log("Home -> onMount")
  })

  beforeUpdate(() => {
    // console.log("Home -> beforeUpdate - isAuthenticated", $isAuthenticated)
    getLedgerBalancePromise = getLedgerBalance(get(daoActor))
  })

  afterUpdate(() => {
    // console.log("Home -> afterUpdate - isAuthenticated", $isAuthenticated)
  })
</script>

<div class="home-main">
  <!-- Render the UI. -->
  {#if $isAuthenticated}
    <!-- User has authenticated with a wallet app. -->
    <!-- <img src={mot} class="bg" alt="logo" /> -->
    <h1 class="slogan">Your MOC Tokens</h1>
    {#await getLedgerBalancePromise}
      <h3 class="slogan">Loading...</h3>
    {:then ledgerBalance}
      {#if ledgerBalance}
        <div class="params-container">
          <ul class="inline">
            <li>
              <span>Ledger Balance</span>
              <pre><code>{getFormattedToken(ledgerBalance)}</code></pre>
            </li>
          </ul>
        </div>
      {/if}
    {:catch error}
      <p style="color: red">Your ledger balance couldn't be loaded.</p>
    {/await}
  {:else}
    <!-- User has not authenticated with a wallet app. -->
    <img src={dfinityLogo} class="App-logo" alt="logo" />
    <p class="example-disabled">You must be authenticated before you can interact with this app. Please connect with a wallet.</p>
  {/if}
</div>

<style>
  .home-main {
    display: flex;
    flex-direction: column;
    justify-content: center;
    color: white;
  }
</style>

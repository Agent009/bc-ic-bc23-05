<script>
  import { get } from "svelte/store"
  import { bc2305Actor, principal } from "../stores"
  import dfinityLogo from "../assets/dfinity.svg"
  import { getMyAirdrops } from "../lib.js"

  //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
  //  REGION:     AIRDROPS     RELATED     ----------   ----------   ----------   ----------   ----------
  //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
  
  let myAirdropsPromise = getMyAirdrops(get(bc2305Actor))
</script>

<div class="view-airdrop">
  {#if $principal}
    {#await myAirdropsPromise}
      <p>Loading...</p>
    {:then airdrops}
      {(console.log("airdrops: ", airdrops), '')}

      {#if airdrops}
        <div id="airdrops">
          <h1>Airdrops</h1>
          {#each airdrops as airdrop}
            {(console.log("airdrop: ", airdrop), '')}
            <Airdrop {airdrop} />
          {/each}
        </div>
      {:else}
        <p style="color: red">You have not received any airdrops yet.</p>
      {/if}
    {:catch error}
      <p style="color: red">{error.message}</p>
    {/await}
  {:else}
    <img src={dfinityLogo} class="App-logo" alt="logo" />
    <p class="example-disabled">You must be authenticated before you can view your airdrops. Please connect with a wallet.</p>
  {/if}
</div>

<style>
  .view-airdrop {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
  }
  h1 {
    color: white;
    font-size: 10vmin;
    font-weight: 700;
  }

  #airdrops {
    display: flex;
    flex-direction: column;
    width: 100%;
    margin-left: 10vmin;
  }
</style>

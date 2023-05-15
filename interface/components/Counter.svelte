<script>
  import { useCanister } from "@connect2ic/svelte"

  let count
  const [bc2305, { loading }] = useCanister("bc2305")

  const refreshBC2305 = async () => {
    const freshCount = await $bc2305.getValue()
    count = freshCount
  }

  const increment = async () => {
    await $bc2305.increment()
    await refreshBC2305()
  }

  $: {
    if (!$loading && $bc2305) {
      refreshBC2305()
    }
  }

</script>
<div class="example">
  <p style="font-size: 2.5em;">{count?.toString()}</p>
  <button class="connect-button" on:click={increment}>+</button>
</div>

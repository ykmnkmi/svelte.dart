<script>
  var count = state<int>(0);
</script>

<button
  on:click={(MouseEvent e) {
    int next = count + 1;
    count = next;
  }}
>clicks: {count}</button>
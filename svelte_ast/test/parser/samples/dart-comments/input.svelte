<script>
  // a leading comment
  var a = 1; // a trailing comment
  var b = 2;

  /** a comment */
  void asd() {
    foo; // trailing
    /* leading comment 1 */
    /* leading comment 2 */
    /* leading comment 3 */
    bar;
    /* trailing comment 1 */
    /* trailing comment 2 */
    /* trailing comment 3 */
  }

  var array = <int>[
    // leading comment 1
    // leading comment 2
    1, // trailing comment 1
    /* trailing comment 2 */
  ];

  var object = (
    // leading comment 1
    // leading comment 2
    a: 1, // trailing comment 1
    /* trailing comment 2 */
  );
</script>

<button
  on:click={// comment
  () {
    /* another comment */
    fn(); // a trailing comment
    /* trailing block comment */
  }}
>
{/* leading block comment */ a}
</button>
{ // leading line comment
  a + b // trailing line comment
  /* trailing block comment */
}
<script>
	import 'foo.dart' deferred as foo;

	void onMount() {
		foo.loadLibrary().then((_) {
			print(foo.main);
		});
	}
</script>
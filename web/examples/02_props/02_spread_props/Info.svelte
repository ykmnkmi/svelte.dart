<script>
	@prop
	var name;

	@prop
	var version;

	@prop
	var speed;

	@prop
	var website;
</script>

<p>
	The <code>{name}</code> package is {speed} fast.
	Download version {version} from <a href="https://www.npmjs.com/package/{name}">npm</a>
	and <a href={website}>learn more here</a>
</p>
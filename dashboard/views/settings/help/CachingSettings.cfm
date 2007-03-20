<h3>Caching Settings</h3>

<p>
The Coldbox cache is an intelligent in-memory cache that can fluctuate according to set parameters.
<br />
</p>

<h3>Object Default Timeout</h3>

<p>This is the default timeout in minutes an object will live in cache if no pre-determined timeout is
used at the time of setting the object in the cache.
</p>

<h3>Last Access Timeout</h3>

<p>This is the timeout in minutes that the cache will use in order to determine when was the last time the
 object was accessed. For example, if this setting is 10 minutes, and Object A has not been accessed in
 the last 10 minutes, then Object A will be purged.
</p>

<h3>Cache Reaping Frequency</h3>

<p>This setting is the frequency in which the cache will try to reap items from the cache. Set this too high and
 your objects will never be purged, set it to low and you will be hitting the cache to frequently. Use it
 wisely my young padawan.
</p>

<h3>Maximum Objects In Cache</h3>

<p>This setting tells the ColdBox cache what is the maximum number of objects to cache. If you select 0, then you open to
	unlimited objects. This is the default, but I encourage you to set this.
</p>

<h3>JVM Free Memory Percentage Threshold</h3>

<p>This is an interesting setting. At any point of time of execution, you can tell how much free JVM memory is available.
	If you set this setting to for example 5%, then whenever the JVM's free memory % goes below 5%, then the cache does
	not cache anymore.  If you set this to 0, then the cache will disregard this setting.
</p>
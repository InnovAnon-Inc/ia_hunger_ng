# Interoperability

The interoperability files (short *i14n* files) are supposed to be used as fallback created within Hunger NG when a mod author can not or will not add support for Hunger NG in their mod for whatever reason.

Hunger NG is meant to be used as library/API by other mods. The i14n files should not be seen as the first solution if in is desirable that another mod in some way interacts with Hunger NG (hunger definition in food items, for example).

Before an i14y file will be added the following things have to be checked/done.

1. Maybe informally contact the original mod author in the mod’s forum thread and point them to [the Hunger NG API definition][api] and ask them to look at this and if they want to add support.
2. Formally file an issue/ticket in the mod’s VCS or issue-tracker or proactively create a pull request at the mod’s VCS adding support for Hunger NG there.
3. If you are a server owner the easiest would be creating an interoperability mod depending on both the original mod and `hunger_ng` and incorporate the Hunger NG API on your own. It’s actually quite simple. The i14y files to exactly the same. See [the i14y section of the API][i14y]) for more details on API things dedicated to the i14y functionality in addition to the regular API calls.
4. Create a pull request on *Hunger NG* adding the desired support. _**Important note:** The i14y code has to be self-contained within the corresponding i14y file. No code, files, or configuration outside the i14y file will be added. Hunger NG is a library/API providing hunger functionality. Interoperability with other mods is just an additional fallback solution if original mod authors won’t add support to their mods._
5. [Start a discussion in the CDB][cdb] requesting interoperability with a specific mods giving as much information as possible (name, author, link to forum and VCS, optimally the item ID to add support for) and not just the mod’s name and “please add” 😊

Go through the list from 1 to 5. Advance by 1 step if the previous step did not result in anything\ or is not desirable.

[api]: https://git.0x7be.net/dirk/hunger_ng/src/branch/main/doc/README.md
[i14y]: https://git.0x7be.net/dirk/hunger_ng/src/branch/main/doc/README.API.md#additional-interoperability-functions
[cdb]: https://content.luanti.org/threads/new/?pid=133

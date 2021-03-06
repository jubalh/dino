using Gee;

using Xmpp.Core;

namespace Xmpp.Presence {

public class Flag : XmppStreamFlag {
    public static FlagIdentity<Flag> IDENTITY = new FlagIdentity<Flag>(NS_URI, "presence");

    private HashMap<string, ConcurrentList<string>> resources = new HashMap<string, ConcurrentList<string>>();
    private HashMap<string, Presence.Stanza> presences = new HashMap<string, Presence.Stanza>();

    public Set<string> get_available_jids() {
        return resources.keys;
    }

    public Gee.List<string>? get_resources(string bare_jid) {
        return resources[bare_jid];
    }

    public Presence.Stanza? get_presence(string full_jid) {
        return presences[full_jid];
    }

    public void add_presence(Presence.Stanza presence) {
        string bare_jid = get_bare_jid(presence.from);
        if (!resources.has_key(bare_jid)) {
            resources[bare_jid] = new ConcurrentList<string>();
        }
        if (resources[bare_jid].contains(presence.from)) {
            resources[bare_jid].remove(presence.from);
        }
        resources[bare_jid].add(presence.from);
        presences[presence.from] = presence;
    }

    public void remove_presence(string jid) {
        string bare_jid = get_bare_jid(jid);
        if (resources.has_key(bare_jid)) {
            if (is_bare_jid(jid)) {
                foreach (string full_jid in resources[jid]) {
                    presences.unset(full_jid);
                }
                resources.unset(jid);
            } else {
                resources[bare_jid].remove(jid);
                if (resources[bare_jid].size == 0) {
                    resources.unset(bare_jid);
                }
                presences.unset(jid);
            }
        }
    }

    public override string get_ns() { return NS_URI; }

    public override string get_id() { return IDENTITY.id; }
}

}
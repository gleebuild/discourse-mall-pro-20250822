
import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "mall-topnav-20250822",
  initialize() {
    withPluginApi("1.8.0", (api) => {
      // 商城：对所有用户可见，跳转到外部商城（可按需改为 /mall）
      api.addNavigationBarItem({
        name: "mall",
        displayName: "商城",
        href: "https://m.lebanx.com",
      });

      // 管理：仅管理员可见，指向 /mall/admin
      api.addNavigationBarItem({
        name: "mall-admin",
        displayName: "管理",
        href: "/mall/admin",
        customFilter: () => {
          const u = api.getCurrentUser();
          return !!(u && u.admin);
        },
      });
    });
  },
};

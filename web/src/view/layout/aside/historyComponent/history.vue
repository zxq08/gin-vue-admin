<template>
  <div class="router-history">
    <el-tabs
      :closable="!(historys.length == 1 && this.$route.name == 'dashboard')"
      @contextmenu.prevent="openContextMenu($event)"
      @tab-click="changeTab"
      @tab-remove="removeTab"
      type="card"
      v-model="activeValue"
    >
      <el-tab-pane
        :key="item.name"
        :label="item.meta.title"
        :name="item.name"
        :tab="item"
        v-for="item in historys"
      ></el-tab-pane>
    </el-tabs>

    <!--自定义右键菜单html代码-->
    <ul
      :style="{ left: left + 'px', top: top + 'px' }"
      class="contextmenu"
      v-show="contextMenuVisible"
    >
      <li @click="closeAll">关闭所有</li>
      <li @click="closeLeft">关闭左侧</li>
      <li @click="closeRight">关闭右侧</li>
      <li @click="closeOther">关闭其他</li>
    </ul>
  </div>
</template>
<script>
import { emitter } from "@/utils/mitt";
import { onUnmounted, reactive, ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
export default {
  name: "HistoryComponent",
  setup() {
    const route = useRoute();
    const router = useRouter();
    const historys = reactive([]);
    const activeValue = ref("dashboard");
    const contextMenuVisible = ref(false);
    const left = ref(0);
    const top = ref(0);
    const isCollapse = ref(false);
    const isMobile = ref(false);
    const rightActive = ref("");

    const openContextMenu = (e) => {
      if (historys.length == 1 && route.name == "dashboard") {
        return false;
      }
      if (e.srcElement.id) {
        contextMenuVisible.value = true;
        let width;
        if (isCollapse.value) {
          width = 54;
        } else {
          width = 220;
        }
        if (isMobile.value) {
          width = 0;
        }
        left.value = e.clientX - width;
        top.value = e.clientY + 10;
        rightActive.value = e.srcElement.id.split("-")[1];
      }
    };
    const closeAll = () => {
      historys.length = 0;
      historys.push({
        name: "dashboard",
        meta: {
          title: "仪表盘",
        },
      });
      router.push({ name: "dashboard" });
      contextMenuVisible.value = false;
      sessionStorage.setItem("historys", JSON.stringify(historys));
    };
    const closeLeft = () => {
      let right;
      const rightIndex = historys.findIndex((item) => {
        if (item.name == rightActive.value) {
          right = item;
        }
        return item.name == rightActive.value;
      });
      const activeIndex = historys.findIndex((item) => item.name == activeValue.value);
      historys.splice(0, rightIndex);
      if (rightIndex > activeIndex) {
        router.push(right);
      }
      sessionStorage.setItem("historys", JSON.stringify(historys));
    };
    const closeRight = () => {
      let right;
      const leftIndex = historys.findIndex((item) => {
        if (item.name == rightActive.value) {
          right = item;
        }
        return item.name == rightActive.value;
      });
      const activeIndex = historys.findIndex((item) => item.name == activeValue.value);
      historys.splice(leftIndex + 1, historys.length);
      if (leftIndex < activeIndex) {
        router.push(right);
      }
      sessionStorage.setItem("historys", JSON.stringify(historys));
    };
    const closeOther = () => {
      let right;
      historys.length = 0;
      const bkHistory = historys.filter((item) => {
        if (item.name == this.rightActive) {
          right = item;
        }
        return item.name == this.rightActive;
      });
      Object.assign(historys, bkHistory);
      router.push(right);
      sessionStorage.setItem("historys", JSON.stringify(historys));
    };
    const setTab = (route) => {
      if (!historys.some((item) => item.name == route.name)) {
        const obj = {};
        obj.name = route.name;
        obj.meta = route.meta;
        obj.query = route.query;
        obj.params = route.params;
        historys.push(obj);
      }
      activeValue.value = route.name;
    };
    const changeTab = (component) => {
      const tab = component.instance.attrs.tab;
      router.push({ name: tab.name, query: tab.query, params: tab.params });
    };
    const removeTab = (tab) => {
      const index = historys.findIndex((item) => item.name == tab);
      if (route.name == tab) {
        if (historys.length == 1) {
          router.push({ name: "dashboard" });
        } else {
          if (index < historys.length - 1) {
            router.push({
              name: historys[index + 1].name,
              query: historys[index + 1].query,
              params: historys[index + 1].params,
            });
          } else {
            router.push({
              name: historys[index - 1].name,
              query: historys[index - 1].query,
              params: historys[index - 1].params,
            });
          }
        }
      }
      historys.splice(index, 1);
    };

    const initFun = () => {
      emitter.on("mobile", (isMobileParams) => {
        isMobile.value = isMobileParams;
      });
      emitter.on("collapse", (isCollapseParams) => {
        isCollapse.value = isCollapseParams;
      });
      const initHistorys = [
        {
          name: "dashboard",
          meta: {
            title: "仪表盘",
          },
        },
      ];

      Object.assign(
        historys,
        JSON.parse(sessionStorage.getItem("historys")) || initHistorys
      );
      setTab(route);
    };
    initFun();
    onUnmounted(() => {
      emitter.off("collapse");
      emitter.off("mobile");
    });

    watch(contextMenuVisible, () => {
      if (contextMenuVisible.value) {
        document.body.addEventListener("click", () => {
          contextMenuVisible.value = false;
        });
      } else {
        document.body.removeEventListener("click", () => {
          contextMenuVisible.value = false;
        });
      }
    });

    watch(route, (to) => {
      const bkHistory = historys.filter((item) => !item.meta.hidden)
      historys.length = 0
      Object.assign(historys,bkHistory)
      setTab(to);
      sessionStorage.setItem("historys", JSON.stringify(historys));
    });

    return {
      historys,
      activeValue,
      contextMenuVisible,
      left,
      top,
      isCollapse,
      isMobile,
      rightActive,
      openContextMenu,
      closeAll,
      closeLeft,
      closeRight,
      closeOther,
      setTab,
      changeTab,
      removeTab,
    };
  }
};
</script>
<style lang="scss">
.contextmenu {
  width: 100px;
  margin: 0;
  border: 1px solid #ccc;
  background: #fff;
  z-index: 3000;
  position: absolute;
  list-style-type: none;
  padding: 5px 0;
  border-radius: 4px;
  font-size: 14px;
  color: #333;
  box-shadow: 2px 2px 3px 0 rgba(0, 0, 0, 0.2);
}
.contextmenu li {
  margin: 0;
  padding: 7px 16px;
}
.contextmenu li:hover {
  background: #f2f2f2;
  cursor: pointer;
}
</style>

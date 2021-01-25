<template>
  <el-drawer title="媒体库" v-model="drawer">
    <div
      style="
        display: flex;
        justify-content: space-around;
        flex-wrap: wrap;
        padding-top: 40px;
      "
    >
      <el-image
        class="header-img-box-list"
        :src="(item.url && item.url.slice(0, 4) !== 'http')?path+item.url:item.url"
        v-for="(item, key) in picList"
        :key="key"
        @click="chooseImg(item.url, target, targetKey)"
      >
        <template #error>
          <div class="header-img-box-list">
            <i class="el-icon-picture-outline"></i>
          </div>
        </template>
      </el-image>
    </div>
  </el-drawer>
</template>

<script>
import { getFileList } from "@/api/fileUploadAndDownload";
import { getCurrentInstance, reactive, ref } from "vue";
export default {
  props: {
    target: [Object],
    targetKey: [String],
  },
  setup() {
    const { ctx } = getCurrentInstance();
    const drawer = ref(false);
    const picList = reactive([]);
    const path = ref(path)
    const chooseImg = (url, target, targetKey) => {
      if (target && targetKey) {
        target[targetKey] = url;
      }
      ctx.$emit("enter-img", url);
      drawer.value = false;
    };
    const open = async () => {
      const res = await getFileList({ page: 1, pageSize: 9999 });
      picList.length = 0;
      Object.assign(picList, res.data.list);
      drawer.value = true;
    };
    return {
      drawer,
      picList,
      chooseImg,
      open,
    };
  },
};
</script>

<style lang="scss">
.header-img-box-list {
  width: 180px;
  height: 180px;
  border: 1px dashed #ccc;
  border-radius: 20px;
  text-align: center;
  line-height: 180px;
  cursor: pointer;
}
</style>

<template>
  <div>
    <el-upload
      :action="`${path}/fileUploadAndDownload/upload`"
      :before-remove="beforeRemove"
      :file-list="fileList"
      :headers="{ 'x-token': token }"
      :limit="10"
      :on-exceed="handleExceed"
      :on-preview="handlePreview"
      :on-remove="handleRemove"
      class="upload-demo"
      multiple
    >
      <el-button size="small" type="primary">点击上传</el-button>
      <template #tip>
        <div class="el-upload__tip">未对文件格式及大小做校验</div>
      </template>
    </el-upload>
  </div>
</template>
<script>
import { useStore } from "vuex";
const globalPath = process.env.VUE_APP_BASE_API;
import { reactive, ref, getCurrentInstance, computed } from "vue";
export default {
  name: "Excel",
  setup() {
    const store = useStore();
    const { ctx } = getCurrentInstance();
    const path = ref(globalPath);
    const fileList = reactive([
      {
        name: "food.jpeg",
        url:
          "https://fuss10.elemecdn.com/3/63/4e7f3a15429bfda99bce42a18cdd1jpeg.jpeg?imageMogr2/thumbnail/360x360/format/webp/quality/100",
      },
      {
        name: "food2.jpeg",
        url:
          "https://fuss10.elemecdn.com/3/63/4e7f3a15429bfda99bce42a18cdd1jpeg.jpeg?imageMogr2/thumbnail/360x360/format/webp/quality/100",
      },
    ]);

    const handleRemove = (file, fileList) => {
      ctx.$message.warning(`共有 ${fileList.length} 个文件，移除了${file.name}`);
    };
    const handlePreview = (file) => {
      ctx.$message.warning(`${file.name}选择完成`);
    };
    const handleExceed = (files, fileList) => {
      ctx.$message.warning(
        `当前限制选择 3 个文件，本次选择了 ${files.length} 个文件，共选择了 ${
          files.length + fileList.length
        } 个文件`
      );
    };
    const beforeRemove = (file, fileList) => {
      return ctx.$confirm(`共有 ${fileList.length} 个文件，确定移除 ${file.name}？`);
    };
    const userInfo = computed(() => store.getters["user/userInfo"]);
    const token = computed(() => store.getters["user/token"]);

    return {
      path,
      fileList,
      handleRemove,
      handlePreview,
      handleExceed,
      beforeRemove,
      userInfo,
      token,
    };
  },
};
</script>

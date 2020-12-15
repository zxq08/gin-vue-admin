<template>
  <div v-loading.fullscreen.lock="fullscreenLoading">
    <div class="upload">
      <el-row>
        <el-col :span="12">
          <el-upload
            :action="`${path}/fileUploadAndDownload/upload`"
            :before-upload="checkFile"
            :headers="{ 'x-token': token }"
            :on-error="uploadError"
            :on-success="uploadSuccess"
            :show-file-list="false"
          >
            <el-button size="small" type="primary">点击上传</el-button>
            <template #tip>
              <div class="el-upload__tip">只能上传jpg/png文件，且不超过500kb</div>
            </template>
          </el-upload>
        </el-col>
        <el-col :span="12">
          带压缩的上传, (512(k)为压缩限制)
          <upload-image v-model="imageUrl" :fileSize="512" :maxWH="1080" />
          已上传文件 {{ imageUrl }}
        </el-col>
      </el-row>

      <el-table :data="tableInfo.tableData" border stripe>
        <el-table-column label="预览" width="100">
          <template #default="scope">
            <CustomPic picType="file" :picSrc="scope.row.url" />
          </template>
        </el-table-column>
        <el-table-column label="日期" prop="UpdatedAt" width="180">
          <template #default="scope">
            <div>{{ formatDate(scope.row.UpdatedAt) }}</div>
          </template>
        </el-table-column>
        <el-table-column label="文件名" prop="name" width="180"></el-table-column>
        <el-table-column label="链接" prop="url" min-width="300"></el-table-column>
        <el-table-column label="标签" prop="tag" width="100">
          <template #default="scope">
            <el-tag
              :type="scope.row.tag === 'jpg' ? 'primary' : 'success'"
              disable-transitions
              >{{ scope.row.tag }}</el-tag
            >
          </template>
        </el-table-column>
        <el-table-column label="操作" width="160">
          <template #default="scope">
            <el-button @click="downloadFile(scope.row)" size="small" type="text"
              >下载</el-button
            >
            <el-button @click="deleteFileFun(scope.row)" size="small" type="text"
              >删除</el-button
            >
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        :current-page="page"
        :page-size="pageSize"
        :page-sizes="[10, 30, 50, 100]"
        :style="{ float: 'right', padding: '20px' }"
        :total="total"
        @current-change="handleCurrentChange"
        @size-change="handleSizeChange"
        layout="total, sizes, prev, pager, next, jumper"
      ></el-pagination>
    </div>
  </div>
</template>

<script>
import { useStore } from "vuex";
import { infoList } from "@/mixins/infoList";
import { getFileList, deleteFile } from "@/api/fileUploadAndDownload";
import { downloadImage } from "@/utils/downloadImg";
import { formatTimeToStr } from "@/utils/date";
import CustomPic from "@/components/customPic";
import UploadImage from "@/components/upload/image.vue";
import { ref, getCurrentInstance, computed } from "vue";
export default {
  name: "Upload",
  components: {
    CustomPic,
    UploadImage,
  },
  setup() {
    const { ctx } = getCurrentInstance();
    const store = useStore();
    const { tableInfo, handleSizeChange, handleCurrentChange, getTableData } = infoList(
      getFileList
    );
    const fullscreenLoading = ref(false);
    const path = ref(process.env.VUE_APP_BASE_API);
    const imageUrl = ref("");
    const token = computed(() => store.getters["user/token"]);
    const formatDate = (time) => {
      if (time != null && time != "") {
        var date = new Date(time);
        return formatTimeToStr(date, "yyyy-MM-dd hh:mm:ss");
      } else {
        return "";
      }
    };

    const deleteFileFun = async (row) => {
      ctx
        .$confirm("此操作将永久文件, 是否继续?", "提示", {
          confirmButtonText: "确定",
          cancelButtonText: "取消",
          type: "warning",
        })
        .then(async () => {
          const res = await deleteFile(row);
          if (res.code == 0) {
            ctx.$message({
              type: "success",
              message: "删除成功!",
            });
            getTableData();
          }
        })
        .catch(() => {
          ctx.$message({
            type: "info",
            message: "已取消删除",
          });
        });
    };
    const checkFile = (file) => {
      fullscreenLoading.value = true;
      const isJPG = file.type === "image/jpeg";
      const isPng = file.type === "image/png";
      const isLt2M = file.size / 1024 / 1024 < 2;
      if (!isJPG && !isPng) {
        ctx.$message.error("上传头像图片只能是 JPG或png 格式!");
        fullscreenLoading.value = false;
      }
      if (!isLt2M) {
        ctx.$message.error("上传头像图片大小不能超过 2MB!");
        fullscreenLoading.value = false;
      }
      return (isPng || isJPG) && isLt2M;
    };
    const uploadSuccess = (res) => {
      fullscreenLoading.value = false;
      if (res.code == 0) {
        ctx.$message({
          type: "success",
          message: "上传成功",
        });
        if (res.code == 0) {
          getTableData();
        }
      } else {
        ctx.$message({
          type: "warning",
          message: res.msg,
        });
      }
    };
    const uploadError = () => {
      ctx.$message({
        type: "error",
        message: "上传失败",
      });
      fullscreenLoading.value = false;
    };
    const downloadFile = (row) => {
      downloadImage(row.url, row.name);
    };
    getTableData()
    return {
      tableInfo,
      handleSizeChange,
      handleCurrentChange,
      fullscreenLoading,
      path,
      imageUrl,
      formatDate,
      deleteFileFun,
      checkFile,
      uploadSuccess,
      uploadError,
      downloadFile,
      token
    };
  }
};
</script>

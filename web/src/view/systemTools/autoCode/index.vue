<template>
  <div>
    <!-- 从数据库直接获取字段 -->
    <el-collapse v-model="activeNames">
      <el-collapse-item name="1">
        <template #title>
          <div :style="{ fontSize: '16px', paddingLeft: '20px' }">
            点这里从现有数据库创建代码
            <i class="header-icon el-icon-thumb"></i>
          </div>
        </template>
        <el-form ref="getTableForm" :inline="true" :model="dbform" label-width="120px">
          <el-form-item label="数据库名" prop="structName">
            <el-select
              @change="getTableFunc"
              v-model="dbform.dbName"
              filterable
              placeholder="请选择数据库"
            >
              <el-option
                v-for="item in dbOptions"
                :key="item.database"
                :label="item.database"
                :value="item.database"
              ></el-option>
            </el-select>
          </el-form-item>
          <el-form-item label="表名" prop="structName">
            <el-select
              v-model="dbform.tableName"
              :disabled="!dbform.dbName"
              filterable
              placeholder="请选择表"
            >
              <el-option
                v-for="item in tableOptions"
                :key="item.tableName"
                :label="item.tableName"
                :value="item.tableName"
              ></el-option>
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button @click="getColumnFunc" type="primary">使用此表创建</el-button>
          </el-form-item>
        </el-form>
      </el-collapse-item>
    </el-collapse>

    <el-divider></el-divider>
    <!-- 初始版本自动化代码工具 -->
    <el-form
      ref="autoCodeForm"
      :rules="rules"
      :model="form"
      label-width="120px"
      :inline="true"
    >
      <el-form-item label="Struct名称" prop="structName">
        <el-input v-model="form.structName" placeholder="首字母自动转换大写"></el-input>
      </el-form-item>
      <el-form-item label="tableName" prop="tableName">
        <el-input v-model="form.tableName" placeholder="指定表名（非必填）"></el-input>
      </el-form-item>
      <el-form-item label="Struct简称" prop="abbreviation">
        <el-input
          v-model="form.abbreviation"
          placeholder="简称会作为入参对象名和路由group"
        ></el-input>
      </el-form-item>
      <el-form-item label="Struct中文名称" prop="description">
        <el-input
          v-model="form.description"
          placeholder="中文描述作为自动api描述"
        ></el-input>
      </el-form-item>
      <el-form-item label="文件名称" prop="packageName">
        <el-input v-model="form.packageName"></el-input>
      </el-form-item>
      <el-form-item label="自动创建api">
        <el-checkbox v-model="form.autoCreateApiToSql"></el-checkbox>
      </el-form-item>
      <el-form-item label="自动移动文件">
        <el-checkbox v-model="form.autoMoveFile"></el-checkbox>
      </el-form-item>
    </el-form>
    <!-- 组件列表 -->
    <div class="button-box clearflex">
      <el-button @click="editAndAddField()" type="primary">新增Field</el-button>
    </div>
    <el-table :data="form.fields" border stripe>
      <el-table-column type="index" label="序列" width="100"></el-table-column>
      <el-table-column prop="fieldName" label="Field名"></el-table-column>
      <el-table-column prop="fieldDesc" label="中文名"></el-table-column>
      <el-table-column prop="fieldJson" label="FieldJson"></el-table-column>
      <el-table-column
        prop="fieldType"
        label="Field数据类型"
        width="130"
      ></el-table-column>
      <el-table-column
        prop="dataType"
        label="数据库字段类型"
        width="130"
      ></el-table-column>
      <el-table-column
        prop="dataTypeLong"
        label="数据库字段长度"
        width="130"
      ></el-table-column>
      <el-table-column prop="columnName" label="数据库字段" width="130"></el-table-column>
      <el-table-column
        prop="comment"
        label="数据库字段描述"
        width="130"
      ></el-table-column>
      <el-table-column
        prop="fieldSearchType"
        label="搜索条件"
        width="130"
      ></el-table-column>
      <el-table-column prop="dictType" label="字典" width="130"></el-table-column>
      <el-table-column label="操作" width="300">
        <template #default="scope">
          <el-button
            size="mini"
            type="primary"
            icon="el-icon-edit"
            @click="editAndAddField(scope.row)"
            >编辑</el-button
          >
          <el-button
            size="mini"
            type="text"
            :disabled="scope.$index == 0"
            @click="moveUpField(scope.$index)"
            >上移</el-button
          >
          <el-button
            size="mini"
            type="text"
            :disabled="scope.$index + 1 == form.fields.length"
            @click="moveDownField(scope.$index)"
            >下移</el-button
          >
          <el-popover placement="top" v-model="scope.row.visible">
            <p>确定删除吗？</p>
            <div style="text-align: right; margin: 0">
              <el-button size="mini" type="text" @click="scope.row.visible = false"
                >取消</el-button
              >
              <el-button type="primary" size="mini" @click="deleteField(scope.$index)"
                >确定</el-button
              >
            </div>
            <template #reference>
              <el-button size="mini" type="danger" icon="el-icon-delete">删除</el-button>
            </template>
          </el-popover>
        </template>
      </el-table-column>
    </el-table>
    <el-tag type="danger"
      >id , created_at , updated_at , deleted_at 会自动生成请勿重复创建</el-tag
    >
    <!-- 组件列表 -->
    <div class="button-box clearflex">
      <el-button @click="enterForm" type="primary">生成代码</el-button>
    </div>
    <!-- 组件弹窗 -->
    <el-dialog title="组件内容" v-model="dialogFlag">
      <FieldDialog v-if="dialogFlag" :dialogMiddle="dialogMiddle" ref="fieldDialog" />
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="closeDialog">取 消</el-button>
          <el-button type="primary" @click="enterDialog">确 定</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>
<script>
const fieldTemplate = {
  fieldName: "",
  fieldDesc: "",
  fieldType: "",
  dataType: "",
  fieldJson: "",
  columnName: "",
  dataTypeLong: "",
  comment: "",
  fieldSearchType: "",
  dictType: "",
};

import FieldDialog from "@/view/systemTools/autoCode/component/fieldDialog.vue";
import { toUpperCase, toHump } from "@/utils/stringFun.js";
import { createTemp, getDB, getTable, getColumn } from "@/api/autoCode.js";
import { getDict } from "@/utils/dictionary";
import { getCurrentInstance, reactive, ref } from "vue";

export default {
  name: "autoCode",
  components: {
    FieldDialog,
  },
  setup() {
    const { ctx } = getCurrentInstance();
    const addFlag = ref("");
    const activeNames = reactive([""]);
    const dbform = reactive({
      dbName: "",
      tableName: "",
    });
    const dbOptions = reactive([]);
    const tableOptions = reactive([]);
    const fdMap = reactive({});
    const form = reactive({
      structName: "",
      tableName: "",
      packageName: "",
      abbreviation: "",
      description: "",
      autoCreateApiToSql: false,
      autoMoveFile: false,
      fields: [],
    });
    const rules = reactive({
      structName: [{ required: true, message: "请输入结构体名称", trigger: "blur" }],
      abbreviation: [{ required: true, message: "请输入结构体简称", trigger: "blur" }],
      description: [{ required: true, message: "请输入结构体描述", trigger: "blur" }],
      packageName: [
        {
          required: true,
          message: "文件名称：sys_xxxx_xxxx",
          trigger: "blur",
        },
      ],
    });
    const dialogMiddle = reactive({});
    const bk = reactive({});
    const dialogFlag = ref(false);

    const editAndAddField = (item) => {
      dialogFlag.value = true;
      if (item) {
        addFlag.value = "edit";
        Object.assign(bk, JSON.parse(JSON.stringify(item)));
        Object.assign(dialogMiddle, item);
      } else {
        addFlag.value = "add";
        Object.assign(dialogMiddle, JSON.parse(JSON.stringify(fieldTemplate)));
      }
    };
    const moveUpField = (index) => {
      if (index == 0) {
        return;
      }
      const oldUpField = form.fields[index - 1];
      form.fields.splice(index - 1, 1);
      form.fields.splice(index, 0, oldUpField);
    };
    const moveDownField = (index) => {
      const fCount = form.fields.length;
      if (index == fCount - 1) {
        return;
      }
      const oldDownField = form.fields[index + 1];
      form.fields.splice(index + 1, 1);
      form.fields.splice(index, 0, oldDownField);
    };
    const enterDialog = () => {
      ctx.$refs.fieldDialog.$refs.fieldDialogFrom.validate((valid) => {
        if (valid) {
          dialogMiddle.fieldName = toUpperCase(dialogMiddle.fieldName);
          if (addFlag.value == "add") {
            form.fields.push(dialogMiddle);
          }
          dialogFlag.value = false;
        } else {
          return false;
        }
      });
    };
    const closeDialog = () => {
      if (addFlag.value == "edit") {
        Object.assign(dialogMiddle, bk);
      }
      dialogFlag.value = false;
    };
    const deleteField = (index) => {
      form.fields.splice(index, 1);
    };
    const enterForm = async () => {
      if (form.fields.length <= 0) {
        ctx.$message({
          type: "error",
          message: "请填写至少一个field",
        });
        return false;
      }
      if (form.fields.some((item) => item.fieldName == form.structName)) {
        ctx.$message({
          type: "error",
          message: "存在与结构体同名的字段",
        });
        return false;
      }
      ctx.$refs.autoCodeForm.validate(async (valid) => {
        if (valid) {
          form.structName = toUpperCase(form.structName);
          if (form.structName == form.abbreviation) {
            ctx.$message({
              type: "error",
              message: "structName和struct简称不能相同",
            });
            return false;
          }
          const data = await createTemp(form);
          if (data.headers?.success == "false") {
            return;
          } else {
            ctx.$message({
              type: "success",
              message: "自动化代码创建成功，正在下载",
            });
          }
          const blob = new Blob([data]);
          const fileName = "ginvueadmin.zip";
          if ("download" in document.createElement("a")) {
            // 不是IE浏览器
            let url = window.URL.createObjectURL(blob);
            let link = document.createElement("a");
            link.style.display = "none";
            link.href = url;
            link.setAttribute("download", fileName);
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link); // 下载完成移除元素
            window.URL.revokeObjectURL(url); // 释放掉blob对象
          } else {
            // IE 10+
            window.navigator.msSaveBlob(blob, fileName);
          }
        } else {
          return false;
        }
      });
    };
    const getDbFunc = async () => {
      const res = await getDB();
      if (res.code == 0) {
        dbOptions.length = 0;
        Object.assign(dbOptions, res.data.dbs);
      }
    };
    const getTableFunc = async () => {
      const res = await getTable({ dbName: dbform.dbName });
      if (res.code == 0) {
        tableOptions.length = 0;
        Object.assign(tableOptions, res.data.tables);
      }
      dbform.tableName = "";
    };
    const getColumnFunc = async () => {
      const gormModelList = ["id", "created_at", "updated_at", "deleted_at"];
      const res = await getColumn(dbform);
      if (res.code == 0) {
        const tbHump = toHump(dbform.tableName);
        form.structName = toUpperCase(tbHump);
        form.tableName = dbform.tableName;
        form.packageName = tbHump;
        form.abbreviation = tbHump;
        form.description = tbHump + "表";
        form.autoCreateApiToSql = true;
        form.fields = [];
        res.data.columns &&
          res.data.columns.map((item) => {
            if (!gormModelList.some((gormfd) => gormfd == item.columnName)) {
              const fbHump = toHump(item.columnName);
              form.fields.push({
                fieldName: toUpperCase(fbHump),
                fieldDesc: item.columnComment || fbHump + "字段",
                fieldType: fdMap[item.dataType],
                dataType: item.dataType,
                fieldJson: fbHump,
                dataTypeLong: item.dataTypeLong,
                columnName: item.columnName,
                comment: item.columnComment,
                fieldSearchType: "",
                dictType: "",
              });
            }
          });
      }
    };
    const setFdMap = () => {
      const fdTypes = ["string", "int", "bool", "float64", "time.Time"];
      fdTypes.map(async (fdtype) => {
        const res = await getDict(fdtype);
        res.map((item) => {
          fdMap[item.label] = fdtype;
        });
      });
    };
    getDbFunc();
    setFdMap();

    return {
      activeNames,
      dbform,
      getTableFunc,
      dbOptions,
      tableOptions,
      getColumnFunc,
      form,
      editAndAddField,
      moveUpField,
      moveDownField,
      deleteField,
      enterForm,
      dialogFlag,
      dialogMiddle,
      closeDialog,
      enterDialog,
      rules
    };
  },
};
</script>
<style scope lang="scss">
.button-box {
  padding: 10px 20px;
  .el-button {
    float: right;
  }
}
</style>

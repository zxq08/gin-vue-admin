<template>
  <div>
    <div class="search-term">
      <el-form :inline="true" :model="searchInfo" class="demo-form-inline">
           {{- range .Fields}}  {{- if .FieldSearchType}} {{- if eq .FieldType "bool" }}
            <el-form-item label="{{.FieldDesc}}" prop="{{.FieldJson}}">
            <el-select v-model="searchInfo.{{.FieldJson}}" clear placeholder="请选择">
                <el-option
                    key="true"
                    label="是"
                    value="true">
                </el-option>
                <el-option
                    key="false"
                    label="否"
                    value="false">
                </el-option>
            </el-select>
            </el-form-item>
                  {{- else }}
        <el-form-item label="{{.FieldDesc}}">
          <el-input placeholder="搜索条件" v-model="searchInfo.{{.FieldJson}}"></el-input>
        </el-form-item> {{ end }} {{ end }}  {{ end }}
        <el-form-item>
          <el-button @click="onSubmit" type="primary">查询</el-button>
        </el-form-item>
        <el-form-item>
          <el-button @click="openDialog" type="primary">新增{{.Description}}</el-button>
        </el-form-item>
        <el-form-item>
          <el-popover placement="top" v-model="deleteVisible" width="160">
            <p>确定要删除吗？</p>
              <div style="text-align: right; margin: 0">
                <el-button @click="deleteVisible = false" size="mini" type="text">取消</el-button>
                <el-button @click="onDelete" size="mini" type="primary">确定</el-button>
              </div>
              <template #reference>
                <el-button icon="el-icon-delete" size="mini" type="danger">批量删除</el-button>
              </template>
          </el-popover>
        </el-form-item>
      </el-form>
    </div>
    <el-table
      :data="tableInfo.tableData"
      @selection-change="handleSelectionChange"
      border
      ref="multipleTable"
      stripe
      style="width: 100%"
      tooltip-effect="dark"
    >
    <el-table-column type="selection" width="55"></el-table-column>
    <el-table-column label="日期" width="180">
         <template #default="scope">{{ "{{ formatDate(scope.row.CreatedAt) }}" }}</template>
    </el-table-column>
    {{range .Fields}}
    {{- if .DictType}}
      <el-table-column label="{{.FieldDesc}}" prop="{{.FieldJson}}" width="120">
        <template #default="scope">
          {{"{{"}}filterDict(scope.row.{{.FieldJson}},{{ .DictType }}Options){{"}}"}}
        </template>
      </el-table-column>
    {{- else if eq .FieldType "bool" }}
    <el-table-column label="{{.FieldDesc}}" prop="{{.FieldJson}}" width="120">
         <template #default="scope">{{ "{{scope.row."}}{{.FieldJson}}{{"|formatBoolean}}" }}</template>
    </el-table-column> {{- else }}
    <el-table-column label="{{.FieldDesc}}" prop="{{.FieldJson}}" width="120"></el-table-column> {{ end }}
    {{ end }}
      <el-table-column fixed="right" label="按钮组"  width="200">
        <template #default="scope">
          <el-button class="table-button" @click="update{{.StructName}}Func(scope.row)" size="small" type="primary" icon="el-icon-edit">变更</el-button>
          <el-popover placement="top" width="160" v-model="scope.row.visible">
            <p>确定要删除吗？</p>
            <div style="text-align: right; margin: 0">
              <el-button size="mini" type="text" @click="scope.row.visible = false">取消</el-button>
              <el-button type="primary" size="mini" @click="delete{{.StructName}}Func(scope.row)">确定</el-button>
            </div>
            <template #reference>
                <el-button type="danger" icon="el-icon-delete" size="mini">删除</el-button>
            </template>
          </el-popover>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      :current-page="tableInfo.page"
      :page-size="tableInfo.pageSize"
      :page-sizes="[10, 30, 50, 100]"
      :style="{float:'right',padding:'20px'}"
      :total="tableInfo.total"
      @current-change="handleCurrentChange"
      @size-change="handleSizeChange"
      layout="total, sizes, prev, pager, next, jumper"
    ></el-pagination>

    <el-dialog :close-on-click-modal="false" :before-close="closeDialog" v-model="dialogFormVisible" title="弹窗操作">
      <el-form class="gva-dialog-body" :model="formData" label-position="right" label-width="80px">
    {{- range .Fields}}
         <el-form-item label="{{.FieldDesc}}:">
      {{- if eq .FieldType "bool" }}
            <el-switch active-color="#13ce66" inactive-color="#ff4949" active-text="是" inactive-text="否" v-model="formData.{{.FieldJson}}" clearable ></el-switch>
      {{ end -}}
      {{- if eq .FieldType "string" }}
            <el-input v-model="formData.{{.FieldJson}}" clearable placeholder="请输入" ></el-input>
      {{ end -}}
      {{- if eq .FieldType "int" }}
      {{- if .DictType}}
             <el-select v-model="formData.{{ .FieldJson }}" placeholder="请选择" clearable>
                 <el-option v-for="(item,key) in {{ .DictType }}Options" :key="key" :label="item.label" :value="item.value"></el-option>
             </el-select>
      {{ else -}}
             <el-input v-model.number="formData.{{ .FieldJson }}" clearable placeholder="请输入"></el-input>
      {{ end -}}
      {{ end -}}
      {{- if eq .FieldType "time.Time" }}
              <el-date-picker type="date" placeholder="选择日期" v-model="formData.{{ .FieldJson }}" clearable></el-date-picker>
       {{ end -}}
       {{- if eq .FieldType "float64" }}
              <el-input-number v-model="formData.{{ .FieldJson }}" :precision="2" clearable></el-input-number>
       {{ end -}}
          </el-form-item>
       {{ end -}}
      </el-form>
      <template #footer>
      <div class="dialog-footer" >
        <el-button @click="closeDialog">取 消</el-button>
        <el-button @click="enterDialog" type="primary">确 定</el-button>
      </div>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import {
    create{{.StructName}},
    delete{{.StructName}},
    delete{{.StructName}}ByIds,
    update{{.StructName}},
    find{{.StructName}},
    get{{.StructName}}List
} from "@/api/{{.PackageName}}";  //  此处请自行替换地址
import { formatTimeToStr } from "@/utils/date";
import { infoList } from "@/mixins/infoList";
import { ref, reactive, getCurrentInstance } from "vue";
export default {
  name: "{{.StructName}}",
  setup(){
    const { ctx } = getCurrentInstance();
    const { tableInfo, handleSizeChange, handleCurrentChange, getTableData, filterDict ,getDictFunc} = infoList(
     get{{ .StructName }}List
    );
      const dialogFormVisible = ref(false);
      const visible = ref(false);
      const type = ref("");
      const deleteVisible = ref(false);
      const multipleSelection = reactive([]);

      {{- range .Fields}}
          {{- if .DictType }}
      const {{ .DictType }}Options = reactive([]);
          {{ end -}}
      {{end -}}

      const formData = reactive({
            ID:0,
            CreatedAt:undefined,
            UpdatedAt:undefined,
            {{range .Fields}}
            {{- if eq .FieldType "bool" -}}
               {{.FieldJson}}:false,
            {{ end -}}
            {{- if eq .FieldType "string" -}}
               {{.FieldJson}}:"",
            {{ end -}}
            {{- if eq .FieldType "int" -}}
               {{.FieldJson}}:0,
            {{ end -}}
            {{- if eq .FieldType "time.Time" -}}
               {{.FieldJson}}:new Date(),
            {{ end -}}
            {{- if eq .FieldType "float64" -}}
               {{.FieldJson}}:0,
            {{ end -}}
            {{ end }}
      });
      const formatDate = (time) => {
        if (time != null && time != "") {
            var date = new Date(time);
            return formatTimeToStr(date, "yyyy-MM-dd hh:mm:ss");
          } else {
            return "";
          }
        };
      const formatBoolean = (bool) => {
        if (bool != null) {
          return bool ? "是" :"否";
        } else {
          return "";
        }
    };
  //条件搜索前端看此方法
      const onSubmit = () => {
        tableInfo.page = 1
        tableInfo.pageSize = 10
        {{- range .Fields}} {{- if eq .FieldType "bool" }}
        if (tableInfo.searchInfo.{{.FieldJson}}==""){
          tableInfo.searchInfo.{{.FieldJson}}=null
        } {{ end }} {{ end }}
        getTableData()
      }
      const handleSelectionChange = (val) => {
        multipleSelection.length = 0
        Object.assign(multipleSelection,val)
      }
      const onDelete = async () => {
        const ids = []
        if(multipleSelection.length == 0){
          ctx.$message({
            type: 'warning',
            message: '请选择要删除的数据'
          })
          return
        }
        multipleSelection &&
          multipleSelection.map(item => {
            ids.push(item.ID)
          })
        const res = await delete{{.StructName}}ByIds({ ids })
        if (res.code == 0) {
          ctx.$message({
            type: 'success',
            message: '删除成功'
          })
          deleteVisible.value = false
          getTableData()
        }
      }
    const update{{.StructName}}Func = async (row) => {
      const res = await find{{.StructName}}({ ID: row.ID });
      type.value = "update";
      if (res.code == 0) {
        Object.assign(formData,res.data.re{{.Abbreviation}});
        dialogFormVisible.value = true;
      }
    }
    const closeDialog = () => {
      dialogFormVisible.value = false;

      Object.assign(formData,{
                    ID:0,
                    CreatedAt:undefined,
                    UpdatedAt:undefined,
                    {{range .Fields}}
                    {{- if eq .FieldType "bool" -}}
                       {{.FieldJson}}:false,
                    {{ end -}}
                    {{- if eq .FieldType "string" -}}
                       {{.FieldJson}}:"",
                    {{ end -}}
                    {{- if eq .FieldType "int" -}}
                       {{.FieldJson}}:0,
                    {{ end -}}
                    {{- if eq .FieldType "time.Time" -}}
                       {{.FieldJson}}:new Date(),
                    {{ end -}}
                    {{- if eq .FieldType "float64" -}}
                       {{.FieldJson}}:0,
                    {{ end -}}
                    {{ end }}
                });
    }
    const delete{{.StructName}}Func =  async(row) => {
      visible.value = false;
      const res = await delete{{.StructName}}({ ID: row.ID });
      if (res.code == 0) {
        ctx.$message({
          type: "success",
          message: "删除成功"
        });
        getTableData();
      }
    }
    const enterDialog = async () => {
      let res;
      switch (type.value) {
        case "create":
          res = await create{{.StructName}}(formData);
          break;
        case "update":
          res = await update{{.StructName}}(formData);
          break;
        default:
          res = await create{{.StructName}}(formData);
          break;
      }
      if (res.code == 0) {
        ctx.$message({
          type:"success",
          message:"创建/更改成功"
        })
        closeDialog();
        getTableData();
      }
    }
    const openDialog = () => {
      type.value = "create";
      dialogFormVisible.value = true;
    }
    const initFunc = async () => {
        await getTableData();
      {{ range .Fields -}}
        {{- if .DictType }}
        Object.assign({{ .DictType }}Options,await getDictFunc("{{.DictType}}"));
        {{ end -}}
      {{- end }}
    }
    initFunc()
    return {
    tableInfo,
    handleSizeChange,
    handleCurrentChange,
    filterDict,
    dialogFormVisible,
    visible,
    type,
    deleteVisible,
    multipleSelection,
    formData,
    formatDate,
    formatBoolean,
    onSubmit,
    handleSelectionChange,
    onDelete,
    update{{.StructName}}Func,
    closeDialog,
    delete{{.StructName}}Func,
    enterDialog,
    openDialog,
    {{ range .Fields -}}
      {{- if .DictType }}
        {{ .DictType }}Options,
      {{ end -}}
    {{- end }}
    }
  }
};
</script>

<style>
</style>
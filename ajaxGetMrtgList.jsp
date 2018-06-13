<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8" %>
<%@ page trimDirectiveWhitespaces="true" %>

<%@page import="java.net.InetAddress" %>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="org.json.simple.parser.JSONParser" %>
<%@page import="org.json.simple.parser.ParseException" %>
<%@page import="org.json.simple.JSONArray" %>
<%@page import="org.apache.commons.io.IOUtils" %>
<%@page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="org.apache.log4j.Logger" %>

<%@include file="00_constants.jsp"%>

<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html;charset=utf-8");
response.setHeader("Pragma","no-cache"); 
response.setHeader("Cache-Control","no-cache"); 
response.setDateHeader("Expires", 0); 

out.clear();	//注意，一定要有out.clear();，要不然client端無法解析XML，會認為XML格式有問題

JSONObject	obj=new JSONObject();

/*********************開始做事吧*********************/

String uid	= (String) session.getAttribute("uid");	//登入用戶資料

if (uid==null || uid.length()<1){
	obj.put("resultCode", gcResultCodeNoLoginInfoFound);
	obj.put("resultText", gcResultTextNoLoginInfoFound);
	out.print(obj);
	out.flush();
	return;
}

String mrtgFile = application.getRealPath("/");
if (!mrtgFile.endsWith("/")) mrtgFile = mrtgFile + "/";
mrtgFile += gcDataFileName;

//開始讀檔案
List l1 = readFileContent(mrtgFile);

if (l1!=null){
	obj.put("resultCode", gcResultCodeSuccess);
	obj.put("resultText", gcResultTextSuccess);
	obj.put("records", l1);
}else{
	obj.put("resultCode", gcResultCodeUnknownError);
	obj.put("resultText", "讀取檔案失敗");
}


out.print(obj);
out.flush();
%>

<%!
/*********************************************************************************************************************/
//讀取某個文字檔的內容
public List readFileContent(String sPath){
	//sPath:檔案的路徑及檔名，呼叫此函數前請先以【String fileName=getServletContext().getRealPath("directory/jsp.txt");】取得檔案的徑名，然後以此徑名做為sPath參數送給此函數
	java.io.File file = new java.io.File(sPath);
	FileInputStream fis = null;
	BufferedInputStream bis = null;
	DataInputStream dis = null;
	String content = "";

	String[] fields2 = {"City", "Area", "Office", "Bandwidth", "F1", "F2", "F3", "F4", "F5", "F6", "ISP", "URL"};
	List  l1 = new LinkedList();
	Map m1 = null;
	int i = 0;
	int j = 0;
	String ss[] = null;
	String tmp = "";
	try {
		fis = new FileInputStream(file);
		bis = new BufferedInputStream(fis);
		dis = new DataInputStream(bis);
		
		while (dis.available() != 0) {
			i ++;
			m1 = new HashMap();
			content = dis.readLine();
			content = new String(content.getBytes("iso8859-1"),"utf-8");
			//writeLog("debug", "content= " + content, "utility");
			ss = content.split(",");
			if (ss!=null && ss.length>0 && i>1){	//第一列是標題，不理他
				//writeLog("debug", "ss length= " + ss.length + ", end= " + ss[ss.length-1], "utility");
				m1 = new HashMap();
				for (j=0;j<ss.length;j++){
					tmp = "";
					if (ss[j]!=null && ss[j].length()>0) tmp = ss[j];
					m1.put(fields2[j], tmp);
				}
				l1.add(m1);
			}
		}
	} catch (FileNotFoundException e) {
		l1 = null;
		writeLog("error", "readFileContent error, sPath: " + sPath + ", desc: " + e.toString(), "utility");
	} catch (IOException e) {
		l1 = null;
		writeLog("error", "readFileContent error, sPath: " + sPath + ", desc: " + e.toString(), "utility");
	}finally{
		if (dis!=null){ try{dis.close();}catch (Exception ignored) {}}
		if (bis!=null){ try{bis.close();}catch (Exception ignored) {}}
		if (fis!=null){ try{fis.close();}catch (Exception ignored) {}}
	}
	return l1;
}

/*********************************************************************************************************************/
public void writeLog(String sLevel, String sLog, String sClass){
	if (sClass==null || sClass.length()<1) sClass = "NoClass";
	Logger logger = Logger.getLogger(sClass);
	writeToLog(sLevel, sLog, logger);
}
public void writeLog(String sLevel, String sLog){
	Logger logger = Logger.getLogger(this.getClass());
	writeToLog(sLevel, sLog, logger);
}
public void writeToLog(String sLevel, String sLog, Logger logger){
	if (sLevel.equalsIgnoreCase("debug"))	logger.debug(sLog);
	if (sLevel.equalsIgnoreCase("info"))	logger.info(sLog);
	if (sLevel.equalsIgnoreCase("warn"))	logger.warn(sLog);
	if (sLevel.equalsIgnoreCase("error"))	logger.error(sLog);
	if (sLevel.equalsIgnoreCase("fatal"))	logger.fatal(sLog);
	//org.apache.log4j.Layout.DateLayout l = DateLayout();
	//logger.info(l.getTimeZone());
}

%>

thrift -gen py -out ../PythonService service.thrift
thrift -gen java:android=true -out ../AndroidApp/app/src/main/java/dydus/com/multicloudservice/generated service.thrift
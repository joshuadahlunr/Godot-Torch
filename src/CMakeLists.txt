target_sources(${PROJECT_NAME} PRIVATE Example.h Example.cpp GDExtensionTemplate.h GDExtensionTemplate.cpp RegisterExtension.cpp win32__assert_fail.cpp)
target_include_directories(${PROJECT_NAME} PRIVATE "src")

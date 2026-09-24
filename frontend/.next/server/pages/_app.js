/*
 * ATTENTION: An "eval-source-map" devtool has been used.
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file with attached SourceMaps in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
(() => {
var exports = {};
exports.id = "pages/_app";
exports.ids = ["pages/_app"];
exports.modules = {

/***/ "./hooks/useAuth.tsx":
/*!***************************!*\
  !*** ./hooks/useAuth.tsx ***!
  \***************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   AuthProvider: () => (/* binding */ AuthProvider),\n/* harmony export */   useAuth: () => (/* binding */ useAuth)\n/* harmony export */ });\n/* harmony import */ var react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react/jsx-dev-runtime */ \"react/jsx-dev-runtime\");\n/* harmony import */ var react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__);\n/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! react */ \"react\");\n/* harmony import */ var react__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(react__WEBPACK_IMPORTED_MODULE_1__);\n\n\nconst defaultProfiles = {\n    student: {\n        id: \"stu_101\",\n        name: \"Alex Johnson\",\n        email: \"alex.johnson@university.edu\",\n        role: \"student\",\n        institution: \"National Institute of Technology\",\n        completionRate: 75\n    },\n    company: {\n        id: \"comp_202\",\n        name: \"TechCorp Industries\",\n        email: \"recruitment@techcorp.com\",\n        role: \"company\",\n        companyName: \"TechCorp Global Solutions\"\n    },\n    teacher: {\n        id: \"teach_303\",\n        name: \"Dr. Sarah Verma\",\n        email: \"s.verma@university.edu\",\n        role: \"teacher\",\n        institution: \"National Institute of Technology - CS Dept\"\n    }\n};\nconst AuthContext = /*#__PURE__*/ (0,react__WEBPACK_IMPORTED_MODULE_1__.createContext)({\n    user: null,\n    role: null,\n    login: ()=>{},\n    logout: ()=>{},\n    switchRole: ()=>{}\n});\nconst AuthProvider = ({ children })=>{\n    const [role, setRole] = (0,react__WEBPACK_IMPORTED_MODULE_1__.useState)(null);\n    const [user, setUser] = (0,react__WEBPACK_IMPORTED_MODULE_1__.useState)(null);\n    (0,react__WEBPACK_IMPORTED_MODULE_1__.useEffect)(()=>{\n        const savedRole = localStorage.getItem(\"sih_user_role\");\n        if (savedRole && defaultProfiles[savedRole]) {\n            setRole(savedRole);\n            setUser(defaultProfiles[savedRole]);\n        } else {\n            // Default to student for seamless dev preview\n            setRole(\"student\");\n            setUser(defaultProfiles[\"student\"]);\n        }\n    }, []);\n    const login = (selectedRole, email)=>{\n        if (selectedRole && defaultProfiles[selectedRole]) {\n            const updatedUser = {\n                ...defaultProfiles[selectedRole],\n                email: email || defaultProfiles[selectedRole].email\n            };\n            setRole(selectedRole);\n            setUser(updatedUser);\n            localStorage.setItem(\"sih_user_role\", selectedRole);\n        }\n    };\n    const switchRole = (newRole)=>{\n        if (newRole && defaultProfiles[newRole]) {\n            setRole(newRole);\n            setUser(defaultProfiles[newRole]);\n            localStorage.setItem(\"sih_user_role\", newRole);\n        }\n    };\n    const logout = ()=>{\n        setRole(null);\n        setUser(null);\n        localStorage.removeItem(\"sih_user_role\");\n    };\n    return /*#__PURE__*/ (0,react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__.jsxDEV)(AuthContext.Provider, {\n        value: {\n            user,\n            role,\n            login,\n            logout,\n            switchRole\n        },\n        children: children\n    }, void 0, false, {\n        fileName: \"D:\\\\Tanay\\\\SIH-Project for industry\\\\SIH-Prototype-industry-\\\\frontend\\\\hooks\\\\useAuth.tsx\",\n        lineNumber: 100,\n        columnNumber: 5\n    }, undefined);\n};\nconst useAuth = ()=>(0,react__WEBPACK_IMPORTED_MODULE_1__.useContext)(AuthContext);\n//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiLi9ob29rcy91c2VBdXRoLnRzeCIsIm1hcHBpbmdzIjoiOzs7Ozs7Ozs7O0FBQXlGO0FBdUJ6RixNQUFNSyxrQkFBOEQ7SUFDbEVDLFNBQVM7UUFDUEMsSUFBSTtRQUNKQyxNQUFNO1FBQ05DLE9BQU87UUFDUEMsTUFBTTtRQUNOQyxhQUFhO1FBQ2JDLGdCQUFnQjtJQUNsQjtJQUNBQyxTQUFTO1FBQ1BOLElBQUk7UUFDSkMsTUFBTTtRQUNOQyxPQUFPO1FBQ1BDLE1BQU07UUFDTkksYUFBYTtJQUNmO0lBQ0FDLFNBQVM7UUFDUFIsSUFBSTtRQUNKQyxNQUFNO1FBQ05DLE9BQU87UUFDUEMsTUFBTTtRQUNOQyxhQUFhO0lBQ2Y7QUFDRjtBQUVBLE1BQU1LLDRCQUFjZixvREFBYUEsQ0FBa0I7SUFDakRnQixNQUFNO0lBQ05QLE1BQU07SUFDTlEsT0FBTyxLQUFPO0lBQ2RDLFFBQVEsS0FBTztJQUNmQyxZQUFZLEtBQU87QUFDckI7QUFFTyxNQUFNQyxlQUFrRCxDQUFDLEVBQUVDLFFBQVEsRUFBRTtJQUMxRSxNQUFNLENBQUNaLE1BQU1hLFFBQVEsR0FBR3BCLCtDQUFRQSxDQUFXO0lBQzNDLE1BQU0sQ0FBQ2MsTUFBTU8sUUFBUSxHQUFHckIsK0NBQVFBLENBQXFCO0lBRXJEQyxnREFBU0EsQ0FBQztRQUNSLE1BQU1xQixZQUFZQyxhQUFhQyxPQUFPLENBQUM7UUFDdkMsSUFBSUYsYUFBYXBCLGVBQWUsQ0FBQ29CLFVBQVUsRUFBRTtZQUMzQ0YsUUFBUUU7WUFDUkQsUUFBUW5CLGVBQWUsQ0FBQ29CLFVBQVU7UUFDcEMsT0FBTztZQUNMLDhDQUE4QztZQUM5Q0YsUUFBUTtZQUNSQyxRQUFRbkIsZUFBZSxDQUFDLFVBQVU7UUFDcEM7SUFDRixHQUFHLEVBQUU7SUFFTCxNQUFNYSxRQUFRLENBQUNVLGNBQXdCbkI7UUFDckMsSUFBSW1CLGdCQUFnQnZCLGVBQWUsQ0FBQ3VCLGFBQWEsRUFBRTtZQUNqRCxNQUFNQyxjQUFjO2dCQUNsQixHQUFHeEIsZUFBZSxDQUFDdUIsYUFBYTtnQkFDaENuQixPQUFPQSxTQUFTSixlQUFlLENBQUN1QixhQUFhLENBQUNuQixLQUFLO1lBQ3JEO1lBQ0FjLFFBQVFLO1lBQ1JKLFFBQVFLO1lBQ1JILGFBQWFJLE9BQU8sQ0FBQyxpQkFBaUJGO1FBQ3hDO0lBQ0Y7SUFFQSxNQUFNUixhQUFhLENBQUNXO1FBQ2xCLElBQUlBLFdBQVcxQixlQUFlLENBQUMwQixRQUFRLEVBQUU7WUFDdkNSLFFBQVFRO1lBQ1JQLFFBQVFuQixlQUFlLENBQUMwQixRQUFRO1lBQ2hDTCxhQUFhSSxPQUFPLENBQUMsaUJBQWlCQztRQUN4QztJQUNGO0lBRUEsTUFBTVosU0FBUztRQUNiSSxRQUFRO1FBQ1JDLFFBQVE7UUFDUkUsYUFBYU0sVUFBVSxDQUFDO0lBQzFCO0lBRUEscUJBQ0UsOERBQUNoQixZQUFZaUIsUUFBUTtRQUFDQyxPQUFPO1lBQUVqQjtZQUFNUDtZQUFNUTtZQUFPQztZQUFRQztRQUFXO2tCQUNsRUU7Ozs7OztBQUdQLEVBQUU7QUFFSyxNQUFNYSxVQUFVLElBQU1qQyxpREFBVUEsQ0FBQ2MsYUFBYSIsInNvdXJjZXMiOlsid2VicGFjazovL3NpaC1wcm90b3R5cGUtZnJvbnRlbmQvLi9ob29rcy91c2VBdXRoLnRzeD9mYmE4Il0sInNvdXJjZXNDb250ZW50IjpbImltcG9ydCBSZWFjdCwgeyBjcmVhdGVDb250ZXh0LCB1c2VDb250ZXh0LCB1c2VTdGF0ZSwgdXNlRWZmZWN0LCBSZWFjdE5vZGUgfSBmcm9tIFwicmVhY3RcIjtcblxuZXhwb3J0IHR5cGUgVXNlclJvbGUgPSBcInN0dWRlbnRcIiB8IFwiY29tcGFueVwiIHwgXCJ0ZWFjaGVyXCIgfCBudWxsO1xuXG5leHBvcnQgaW50ZXJmYWNlIFVzZXJQcm9maWxlIHtcbiAgaWQ6IHN0cmluZztcbiAgbmFtZTogc3RyaW5nO1xuICBlbWFpbDogc3RyaW5nO1xuICByb2xlOiBVc2VyUm9sZTtcbiAgYXZhdGFyPzogc3RyaW5nO1xuICBpbnN0aXR1dGlvbj86IHN0cmluZztcbiAgY29tcGFueU5hbWU/OiBzdHJpbmc7XG4gIGNvbXBsZXRpb25SYXRlPzogbnVtYmVyO1xufVxuXG5pbnRlcmZhY2UgQXV0aENvbnRleHRUeXBlIHtcbiAgdXNlcjogVXNlclByb2ZpbGUgfCBudWxsO1xuICByb2xlOiBVc2VyUm9sZTtcbiAgbG9naW46IChyb2xlOiBVc2VyUm9sZSwgZW1haWw/OiBzdHJpbmcpID0+IHZvaWQ7XG4gIGxvZ291dDogKCkgPT4gdm9pZDtcbiAgc3dpdGNoUm9sZTogKHJvbGU6IFVzZXJSb2xlKSA9PiB2b2lkO1xufVxuXG5jb25zdCBkZWZhdWx0UHJvZmlsZXM6IFJlY29yZDxOb25OdWxsYWJsZTxVc2VyUm9sZT4sIFVzZXJQcm9maWxlPiA9IHtcbiAgc3R1ZGVudDoge1xuICAgIGlkOiBcInN0dV8xMDFcIixcbiAgICBuYW1lOiBcIkFsZXggSm9obnNvblwiLFxuICAgIGVtYWlsOiBcImFsZXguam9obnNvbkB1bml2ZXJzaXR5LmVkdVwiLFxuICAgIHJvbGU6IFwic3R1ZGVudFwiLFxuICAgIGluc3RpdHV0aW9uOiBcIk5hdGlvbmFsIEluc3RpdHV0ZSBvZiBUZWNobm9sb2d5XCIsXG4gICAgY29tcGxldGlvblJhdGU6IDc1LFxuICB9LFxuICBjb21wYW55OiB7XG4gICAgaWQ6IFwiY29tcF8yMDJcIixcbiAgICBuYW1lOiBcIlRlY2hDb3JwIEluZHVzdHJpZXNcIixcbiAgICBlbWFpbDogXCJyZWNydWl0bWVudEB0ZWNoY29ycC5jb21cIixcbiAgICByb2xlOiBcImNvbXBhbnlcIixcbiAgICBjb21wYW55TmFtZTogXCJUZWNoQ29ycCBHbG9iYWwgU29sdXRpb25zXCIsXG4gIH0sXG4gIHRlYWNoZXI6IHtcbiAgICBpZDogXCJ0ZWFjaF8zMDNcIixcbiAgICBuYW1lOiBcIkRyLiBTYXJhaCBWZXJtYVwiLFxuICAgIGVtYWlsOiBcInMudmVybWFAdW5pdmVyc2l0eS5lZHVcIixcbiAgICByb2xlOiBcInRlYWNoZXJcIixcbiAgICBpbnN0aXR1dGlvbjogXCJOYXRpb25hbCBJbnN0aXR1dGUgb2YgVGVjaG5vbG9neSAtIENTIERlcHRcIixcbiAgfSxcbn07XG5cbmNvbnN0IEF1dGhDb250ZXh0ID0gY3JlYXRlQ29udGV4dDxBdXRoQ29udGV4dFR5cGU+KHtcbiAgdXNlcjogbnVsbCxcbiAgcm9sZTogbnVsbCxcbiAgbG9naW46ICgpID0+IHt9LFxuICBsb2dvdXQ6ICgpID0+IHt9LFxuICBzd2l0Y2hSb2xlOiAoKSA9PiB7fSxcbn0pO1xuXG5leHBvcnQgY29uc3QgQXV0aFByb3ZpZGVyOiBSZWFjdC5GQzx7IGNoaWxkcmVuOiBSZWFjdE5vZGUgfT4gPSAoeyBjaGlsZHJlbiB9KSA9PiB7XG4gIGNvbnN0IFtyb2xlLCBzZXRSb2xlXSA9IHVzZVN0YXRlPFVzZXJSb2xlPihudWxsKTtcbiAgY29uc3QgW3VzZXIsIHNldFVzZXJdID0gdXNlU3RhdGU8VXNlclByb2ZpbGUgfCBudWxsPihudWxsKTtcblxuICB1c2VFZmZlY3QoKCkgPT4ge1xuICAgIGNvbnN0IHNhdmVkUm9sZSA9IGxvY2FsU3RvcmFnZS5nZXRJdGVtKFwic2loX3VzZXJfcm9sZVwiKSBhcyBVc2VyUm9sZTtcbiAgICBpZiAoc2F2ZWRSb2xlICYmIGRlZmF1bHRQcm9maWxlc1tzYXZlZFJvbGVdKSB7XG4gICAgICBzZXRSb2xlKHNhdmVkUm9sZSk7XG4gICAgICBzZXRVc2VyKGRlZmF1bHRQcm9maWxlc1tzYXZlZFJvbGVdKTtcbiAgICB9IGVsc2Uge1xuICAgICAgLy8gRGVmYXVsdCB0byBzdHVkZW50IGZvciBzZWFtbGVzcyBkZXYgcHJldmlld1xuICAgICAgc2V0Um9sZShcInN0dWRlbnRcIik7XG4gICAgICBzZXRVc2VyKGRlZmF1bHRQcm9maWxlc1tcInN0dWRlbnRcIl0pO1xuICAgIH1cbiAgfSwgW10pO1xuXG4gIGNvbnN0IGxvZ2luID0gKHNlbGVjdGVkUm9sZTogVXNlclJvbGUsIGVtYWlsPzogc3RyaW5nKSA9PiB7XG4gICAgaWYgKHNlbGVjdGVkUm9sZSAmJiBkZWZhdWx0UHJvZmlsZXNbc2VsZWN0ZWRSb2xlXSkge1xuICAgICAgY29uc3QgdXBkYXRlZFVzZXIgPSB7XG4gICAgICAgIC4uLmRlZmF1bHRQcm9maWxlc1tzZWxlY3RlZFJvbGVdLFxuICAgICAgICBlbWFpbDogZW1haWwgfHwgZGVmYXVsdFByb2ZpbGVzW3NlbGVjdGVkUm9sZV0uZW1haWwsXG4gICAgICB9O1xuICAgICAgc2V0Um9sZShzZWxlY3RlZFJvbGUpO1xuICAgICAgc2V0VXNlcih1cGRhdGVkVXNlcik7XG4gICAgICBsb2NhbFN0b3JhZ2Uuc2V0SXRlbShcInNpaF91c2VyX3JvbGVcIiwgc2VsZWN0ZWRSb2xlKTtcbiAgICB9XG4gIH07XG5cbiAgY29uc3Qgc3dpdGNoUm9sZSA9IChuZXdSb2xlOiBVc2VyUm9sZSkgPT4ge1xuICAgIGlmIChuZXdSb2xlICYmIGRlZmF1bHRQcm9maWxlc1tuZXdSb2xlXSkge1xuICAgICAgc2V0Um9sZShuZXdSb2xlKTtcbiAgICAgIHNldFVzZXIoZGVmYXVsdFByb2ZpbGVzW25ld1JvbGVdKTtcbiAgICAgIGxvY2FsU3RvcmFnZS5zZXRJdGVtKFwic2loX3VzZXJfcm9sZVwiLCBuZXdSb2xlKTtcbiAgICB9XG4gIH07XG5cbiAgY29uc3QgbG9nb3V0ID0gKCkgPT4ge1xuICAgIHNldFJvbGUobnVsbCk7XG4gICAgc2V0VXNlcihudWxsKTtcbiAgICBsb2NhbFN0b3JhZ2UucmVtb3ZlSXRlbShcInNpaF91c2VyX3JvbGVcIik7XG4gIH07XG5cbiAgcmV0dXJuIChcbiAgICA8QXV0aENvbnRleHQuUHJvdmlkZXIgdmFsdWU9e3sgdXNlciwgcm9sZSwgbG9naW4sIGxvZ291dCwgc3dpdGNoUm9sZSB9fT5cbiAgICAgIHtjaGlsZHJlbn1cbiAgICA8L0F1dGhDb250ZXh0LlByb3ZpZGVyPlxuICApO1xufTtcblxuZXhwb3J0IGNvbnN0IHVzZUF1dGggPSAoKSA9PiB1c2VDb250ZXh0KEF1dGhDb250ZXh0KTtcbiJdLCJuYW1lcyI6WyJSZWFjdCIsImNyZWF0ZUNvbnRleHQiLCJ1c2VDb250ZXh0IiwidXNlU3RhdGUiLCJ1c2VFZmZlY3QiLCJkZWZhdWx0UHJvZmlsZXMiLCJzdHVkZW50IiwiaWQiLCJuYW1lIiwiZW1haWwiLCJyb2xlIiwiaW5zdGl0dXRpb24iLCJjb21wbGV0aW9uUmF0ZSIsImNvbXBhbnkiLCJjb21wYW55TmFtZSIsInRlYWNoZXIiLCJBdXRoQ29udGV4dCIsInVzZXIiLCJsb2dpbiIsImxvZ291dCIsInN3aXRjaFJvbGUiLCJBdXRoUHJvdmlkZXIiLCJjaGlsZHJlbiIsInNldFJvbGUiLCJzZXRVc2VyIiwic2F2ZWRSb2xlIiwibG9jYWxTdG9yYWdlIiwiZ2V0SXRlbSIsInNlbGVjdGVkUm9sZSIsInVwZGF0ZWRVc2VyIiwic2V0SXRlbSIsIm5ld1JvbGUiLCJyZW1vdmVJdGVtIiwiUHJvdmlkZXIiLCJ2YWx1ZSIsInVzZUF1dGgiXSwic291cmNlUm9vdCI6IiJ9\n//# sourceURL=webpack-internal:///./hooks/useAuth.tsx\n");

/***/ }),

/***/ "./pages/_app.tsx":
/*!************************!*\
  !*** ./pages/_app.tsx ***!
  \************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

"use strict";
eval("__webpack_require__.r(__webpack_exports__);\n/* harmony export */ __webpack_require__.d(__webpack_exports__, {\n/* harmony export */   \"default\": () => (/* binding */ App)\n/* harmony export */ });\n/* harmony import */ var react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! react/jsx-dev-runtime */ \"react/jsx-dev-runtime\");\n/* harmony import */ var react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__);\n/* harmony import */ var _hooks_useAuth__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../hooks/useAuth */ \"./hooks/useAuth.tsx\");\n/* harmony import */ var _style_globals_css__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../style/globals.css */ \"./style/globals.css\");\n/* harmony import */ var _style_globals_css__WEBPACK_IMPORTED_MODULE_2___default = /*#__PURE__*/__webpack_require__.n(_style_globals_css__WEBPACK_IMPORTED_MODULE_2__);\n\n\n\nfunction App({ Component, pageProps }) {\n    return /*#__PURE__*/ (0,react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__.jsxDEV)(_hooks_useAuth__WEBPACK_IMPORTED_MODULE_1__.AuthProvider, {\n        children: /*#__PURE__*/ (0,react_jsx_dev_runtime__WEBPACK_IMPORTED_MODULE_0__.jsxDEV)(Component, {\n            ...pageProps\n        }, void 0, false, {\n            fileName: \"D:\\\\Tanay\\\\SIH-Project for industry\\\\SIH-Prototype-industry-\\\\frontend\\\\pages\\\\_app.tsx\",\n            lineNumber: 8,\n            columnNumber: 7\n        }, this)\n    }, void 0, false, {\n        fileName: \"D:\\\\Tanay\\\\SIH-Project for industry\\\\SIH-Prototype-industry-\\\\frontend\\\\pages\\\\_app.tsx\",\n        lineNumber: 7,\n        columnNumber: 5\n    }, this);\n}\n//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiLi9wYWdlcy9fYXBwLnRzeCIsIm1hcHBpbmdzIjoiOzs7Ozs7Ozs7O0FBQ2dEO0FBQ2xCO0FBRWYsU0FBU0MsSUFBSSxFQUFFQyxTQUFTLEVBQUVDLFNBQVMsRUFBWTtJQUM1RCxxQkFDRSw4REFBQ0gsd0RBQVlBO2tCQUNYLDRFQUFDRTtZQUFXLEdBQUdDLFNBQVM7Ozs7Ozs7Ozs7O0FBRzlCIiwic291cmNlcyI6WyJ3ZWJwYWNrOi8vc2loLXByb3RvdHlwZS1mcm9udGVuZC8uL3BhZ2VzL19hcHAudHN4PzJmYmUiXSwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IHR5cGUgeyBBcHBQcm9wcyB9IGZyb20gXCJuZXh0L2FwcFwiO1xuaW1wb3J0IHsgQXV0aFByb3ZpZGVyIH0gZnJvbSBcIi4uL2hvb2tzL3VzZUF1dGhcIjtcbmltcG9ydCBcIi4uL3N0eWxlL2dsb2JhbHMuY3NzXCI7XG5cbmV4cG9ydCBkZWZhdWx0IGZ1bmN0aW9uIEFwcCh7IENvbXBvbmVudCwgcGFnZVByb3BzIH06IEFwcFByb3BzKSB7XG4gIHJldHVybiAoXG4gICAgPEF1dGhQcm92aWRlcj5cbiAgICAgIDxDb21wb25lbnQgey4uLnBhZ2VQcm9wc30gLz5cbiAgICA8L0F1dGhQcm92aWRlcj5cbiAgKTtcbn1cbiJdLCJuYW1lcyI6WyJBdXRoUHJvdmlkZXIiLCJBcHAiLCJDb21wb25lbnQiLCJwYWdlUHJvcHMiXSwic291cmNlUm9vdCI6IiJ9\n//# sourceURL=webpack-internal:///./pages/_app.tsx\n");

/***/ }),

/***/ "./style/globals.css":
/*!***************************!*\
  !*** ./style/globals.css ***!
  \***************************/
/***/ (() => {



/***/ }),

/***/ "react":
/*!************************!*\
  !*** external "react" ***!
  \************************/
/***/ ((module) => {

"use strict";
module.exports = require("react");

/***/ }),

/***/ "react/jsx-dev-runtime":
/*!****************************************!*\
  !*** external "react/jsx-dev-runtime" ***!
  \****************************************/
/***/ ((module) => {

"use strict";
module.exports = require("react/jsx-dev-runtime");

/***/ })

};
;

// load runtime
var __webpack_require__ = require("../webpack-runtime.js");
__webpack_require__.C(exports);
var __webpack_exec__ = (moduleId) => (__webpack_require__(__webpack_require__.s = moduleId))
var __webpack_exports__ = (__webpack_exec__("./pages/_app.tsx"));
module.exports = __webpack_exports__;

})();
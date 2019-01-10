import './styles.pcss';

import { setupEditor, updateEditor } from './editor';

const fileApi = "/api/files" + location.pathname + "/text";

setupEditor();

fetch(fileApi)
    .then(resp => resp.json())
    .then(fileData => updateEditor(fileData));

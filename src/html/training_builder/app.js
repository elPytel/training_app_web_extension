// Minimal JS to build XML matching trenink.xsd and provide preview/download
(function () {
  function $(id) { return document.getElementById(id); }

  let definitions = [];
  let exercisesInUnit = [];

  function escapeXml(str) {
    if (str == null) return '';
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&apos;');
  }

  function renderLists() {
    const defs = $('defs-list');
    defs.innerHTML = '';
    definitions.forEach((d, i) => {
      const li = document.createElement('li');
      li.textContent = `${d.id}: ${d.name} (${d.category})`;
      const del = document.createElement('button'); del.textContent = 'Remove';
      del.onclick = () => { definitions.splice(i,1); renderLists(); };
      li.appendChild(document.createTextNode(' ')); li.appendChild(del);
      defs.appendChild(li);
    });

    const units = $('units-list');
    units.innerHTML = '';
    exercisesInUnit.forEach((u,i) => {
      const li = document.createElement('li');
      li.textContent = `${u.orderIndex}: ${u.exerciseId} reps=${u.reps || ''} sets=${u.sets || ''}`;
      const del = document.createElement('button'); del.textContent = 'Remove';
      del.onclick = () => { exercisesInUnit.splice(i,1); renderLists(); };
      li.appendChild(document.createTextNode(' ')); li.appendChild(del);
      units.appendChild(li);
    });
  }

  function addDefinitionFromForm() {
    const id = $('def-id').value.trim();
    if (!id) { alert('Definition id required'); return; }
    if (definitions.some(d=>d.id===id)) { alert('Duplicate id'); return; }
    const def = {
      id,
      name: $('def-name').value.trim(),
      category: $('def-category').value,
      description: $('def-description').value.trim(),
      mediaType: $('def-mediaType').value,
      mediaUrl: $('def-mediaUrl').value.trim(),
      muscleGroups: $('def-muscles').value.split(',').map(s=>s.trim()).filter(Boolean),
      isDefault: $('def-isDefault').checked ? 'True' : 'False'
    };
    definitions.push(def);
    renderLists();
    $('def-form').reset();
  }

  function addUnitExerciseFromForm() {
    const id = `u${Date.now()}`;
    const exerciseId = $('unit-exerciseId').value.trim();
    if (!exerciseId) { alert('exerciseId required'); return; }
    const item = {
      id,
      exerciseId,
      isDistanceEnabled: $('ue-distance').checked ? 'True' : 'False',
      isRepsEnabled: $('ue-repsEnabled').checked ? 'True' : 'False',
      isRestEnabled: $('ue-restEnabled').checked ? 'True' : 'False',
      isRirEnabled: $('ue-rirEnabled').checked ? 'True' : 'False',
      isTimeEnabled: $('ue-timeEnabled').checked ? 'True' : 'False',
      isWeightEnabled: $('ue-weightEnabled').checked ? 'True' : 'False',
      orderIndex: Number($('ue-order').value) || (exercisesInUnit.length+1),
      reps: $('ue-reps').value ? Number($('ue-reps').value) : undefined,
      rest: $('ue-rest').value ? Number($('ue-rest').value) : undefined,
      sets: $('ue-sets').value ? Number($('ue-sets').value) : undefined,
      trainingUnitId: $('unit-id').value || ''
    };
    exercisesInUnit.push(item);
    exercisesInUnit.sort((a,b)=>a.orderIndex-b.orderIndex);
    renderLists();
    $('unit-ex-form').reset();
  }

  function buildXml() {
    const clientId = escapeXml($('clientId').value.trim());
    const unitId = escapeXml($('unit-id').value.trim());
    const unitName = escapeXml($('unit-name').value.trim());
    const unitNote = escapeXml($('unit-note').value.trim());

    let out = '<?xml version="1.0" encoding="utf-8"?>\n<root>\n';

    out += '  <exerciseDefinitions>\n';
    definitions.forEach(d => {
      out += `    <item id="${escapeXml(d.id)}">\n`;
      out += `      <name>${escapeXml(d.name)}</name>\n`;
      out += `      <category>${escapeXml(d.category)}</category>\n`;
      if (d.description) out += `      <description>${escapeXml(d.description)}</description>\n`;
      if (d.mediaType || d.mediaUrl) {
        out += '      <media>\n';
        out += `        <mediaType>${escapeXml(d.mediaType||'NONE')}</mediaType>\n`;
        if (d.mediaUrl) out += `        <mediaUrl>${escapeXml(d.mediaUrl)}</mediaUrl>\n`;
        out += '      </media>\n';
      }
      if (d.muscleGroups && d.muscleGroups.length) {
        out += '      <muscleGroups>\n';
        d.muscleGroups.forEach(m => { out += `        <item>${escapeXml(m)}</item>\n`; });
        out += '      </muscleGroups>\n';
      }
      out += `      <isDefault>${escapeXml(d.isDefault)}</isDefault>\n`;
      out += '    </item>\n';
    });
    out += '  </exerciseDefinitions>\n';

    out += '  <exercisesInUnit>\n';
    exercisesInUnit.forEach(e => {
      out += `    <item id="${escapeXml(e.id)}">\n`;
      out += `      <exerciseId>${escapeXml(e.exerciseId)}</exerciseId>\n`;
      out += `      <isDistanceEnabled>${escapeXml(e.isDistanceEnabled)}</isDistanceEnabled>\n`;
      out += `      <isRepsEnabled>${escapeXml(e.isRepsEnabled)}</isRepsEnabled>\n`;
      out += `      <isRestEnabled>${escapeXml(e.isRestEnabled)}</isRestEnabled>\n`;
      out += `      <isRirEnabled>${escapeXml(e.isRirEnabled)}</isRirEnabled>\n`;
      out += `      <isTimeEnabled>${escapeXml(e.isTimeEnabled)}</isTimeEnabled>\n`;
      out += `      <isWeightEnabled>${escapeXml(e.isWeightEnabled)}</isWeightEnabled>\n`;
      out += `      <orderIndex>${escapeXml(e.orderIndex)}</orderIndex>\n`;
      if (e.reps !== undefined) out += `      <reps>${escapeXml(e.reps)}</reps>\n`;
      if (e.rest !== undefined) out += `      <rest>${escapeXml(e.rest)}</rest>\n`;
      if (e.sets !== undefined) out += `      <sets>${escapeXml(e.sets)}</sets>\n`;
      out += `      <trainingUnitId>${escapeXml(e.trainingUnitId||unitId)}</trainingUnitId>\n`;
      out += '    </item>\n';
    });
    out += '  </exercisesInUnit>\n';

    out += '  <unit>\n';
    out += `    <clientId>${clientId}</clientId>\n`;
    out += `    <id>${unitId}</id>\n`;
    out += `    <name>${unitName}</name>\n`;
    if (unitNote) out += `    <note>${unitNote}</note>\n`;
    out += '  </unit>\n';

    out += '</root>\n';
    return out;
  }

  function previewXml() {
    $('preview').textContent = buildXml();
  }

  function downloadXml() {
    const xml = buildXml();
    const blob = new Blob([xml], {type: 'application/xml'});
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = ($('unit-id').value || 'training') + '.xml';
    document.body.appendChild(a); a.click(); a.remove();
  }

  window.addEventListener('load', ()=>{
    $('def-add').addEventListener('click', addDefinitionFromForm);
    $('unit-add').addEventListener('click', addUnitExerciseFromForm);
    $('btn-preview').addEventListener('click', previewXml);
    $('btn-download').addEventListener('click', downloadXml);
    renderLists();
  });
})();

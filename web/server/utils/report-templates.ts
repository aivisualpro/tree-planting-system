export const reportBaseStyles = `
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap');
    @page { size: A4; margin: 0; }
    body { font-family: 'Inter', sans-serif; -webkit-print-color-adjust: exact; }
    .page-break { page-break-after: always; }
    .no-break { page-break-inside: avoid; }
    .gradient-green { background: linear-gradient(135deg, #166534 0%, #15803d 100%); }
  </style>
`;

export function getMonthlyCountryReportTemplate(data: any) {
  return `
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        ${reportBaseStyles}
      </head>
      <body class="text-gray-800">
        <!-- Cover Page -->
        <div class="h-[297mm] w-[210mm] flex flex-col justify-between p-20 gradient-green text-white page-break relative overflow-hidden">
          <div class="absolute top-[-10%] right-[-10%] w-[50%] h-[50%] bg-white/10 rounded-full blur-3xl"></div>
          <div class="relative z-10">
            <div class="bg-white p-4 rounded-xl inline-block mb-12">
              <img src="${data.logoUrl || 'https://aivisualpro.com/logo.png'}" class="h-12" alt="NGO Logo" />
            </div>
            <h1 class="text-7xl font-extrabold mb-4 tracking-tighter">Impact<br/>Report</h1>
            <div class="h-2 w-24 bg-white/50 mb-8"></div>
            <h2 class="text-3xl font-semibold opacity-90 uppercase tracking-[0.2em]">${data.countryName}</h2>
          </div>
          
          <div class="relative z-10 border-t border-white/20 pt-12">
            <p class="text-3xl font-medium mb-2">${data.monthYear}</p>
            <p class="text-white/60 text-lg font-mono uppercase tracking-widest">Confidential Reporting</p>
          </div>
        </div>

        <!-- TOC -->
        <div class="page-break p-20 min-h-[297mm]">
          <h2 class="text-4xl font-black text-green-900 mb-12 border-l-8 border-green-600 pl-6">Contents</h2>
          <div class="space-y-6">
            ${['Executive Summary', 'Visits Timeline', 'Top Species Distribution', 'Community Breakdown', 'Strategic Recommendations'].map((item, i) => `
              <div class="flex items-center gap-4 group">
                <span class="text-green-600 font-bold text-xl w-8">0${i + 1}</span>
                <span class="text-2xl font-semibold text-gray-700 flex-grow">${item}</span>
                <div class="flex-grow border-b-2 border-dotted border-gray-200 mx-4"></div>
                <span class="text-xl font-bold text-gray-400">${3 + i}</span>
              </div>
            `).join('')}
          </div>
        </div>

        <!-- Executive Summary -->
        <div class="p-20 min-h-[297mm]">
          <h2 class="text-4xl font-black text-green-900 mb-12 border-l-8 border-green-600 pl-6">Executive Summary</h2>
          
          <div class="grid grid-cols-2 gap-8 mb-16">
            <div class="bg-green-50 p-10 rounded-3xl border border-green-100 relative overflow-hidden">
               <div class="absolute top-0 right-0 p-4 opacity-10">
                 <svg class="w-24 h-24" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2L4.5 20.29l.71.71L12 18l6.79 3 .71-.71z"/></svg>
               </div>
               <p class="text-green-700 font-bold uppercase tracking-widest text-sm mb-4">Total Trees Planted</p>
               <p class="text-6xl font-black text-green-900">${data.totalTrees.toLocaleString()}</p>
            </div>
            <div class="bg-blue-50 p-10 rounded-3xl border border-blue-100 relative overflow-hidden">
               <div class="absolute top-0 right-0 p-4 opacity-10">
                 <svg class="w-24 h-24" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg>
               </div>
               <p class="text-blue-700 font-bold uppercase tracking-widest text-sm mb-4">Successful Field Visits</p>
               <p class="text-6xl font-black text-blue-900">${data.totalVisits.toLocaleString()}</p>
            </div>
          </div>

          <h3 class="text-2xl font-bold text-gray-800 mb-6 uppercase tracking-wider">Top Performing Species</h3>
          <div class="space-y-4">
             ${(data.topSpecies || []).map((s: any) => `
               <div class="flex items-center gap-6 p-4 bg-gray-50 rounded-2xl border border-gray-100">
                  <div class="w-16 h-16 bg-white rounded-xl shadow-sm flex items-center justify-center font-bold text-green-600 text-xl">
                    ${s.percentage}%
                  </div>
                  <div>
                    <p class="text-lg font-bold text-gray-900">${s.name}</p>
                    <p class="text-sm text-gray-500 italic">${s.scientificName}</p>
                  </div>
                  <div class="ml-auto text-right">
                    <p class="text-xl font-black text-green-700">${s.count.toLocaleString()}</p>
                    <p class="text-xs text-gray-400 uppercase font-bold tracking-tighter">Seedlings</p>
                  </div>
               </div>
             `).join('')}
          </div>
        </div>
      </body>
    </html>
  `;
}

export function getVisitReportTemplate(data: any) {
  return `
    <html>
      <head>${reportBaseStyles}</head>
      <body class="p-12 text-gray-800">
        <div class="flex justify-between items-start mb-12 border-b pb-8">
           <div>
             <h1 class="text-4xl font-black text-green-900 mb-2 tracking-tighter">Visit Report</h1>
             <p class="text-gray-500 font-mono">ID: ${data.visitId}</p>
           </div>
           <img src="${data.logoUrl || 'https://aivisualpro.com/logo.png'}" class="h-12" />
        </div>

        <div class="grid grid-cols-3 gap-8 mb-12">
          <div class="col-span-2 space-y-6">
            <section>
              <h3 class="text-xs font-bold uppercase text-gray-400 tracking-[0.2em] mb-2">Location Detail</h3>
              <p class="text-2xl font-bold text-gray-900">${data.communityName}, ${data.countryName}</p>
              <p class="text-gray-600">${data.subwatershedName}</p>
            </section>
            <section>
              <h3 class="text-xs font-bold uppercase text-gray-400 tracking-[0.2em] mb-2">Activities Conducted</h3>
              <p class="text-xl font-semibold text-gray-800">${data.activityName}</p>
            </section>
          </div>
          <div class="bg-gray-50 p-6 rounded-2xl border border-gray-100">
            <h3 class="text-xs font-bold uppercase text-gray-400 tracking-[0.2em] mb-4 text-center">Trees Planted</h3>
            <p class="text-5xl font-black text-green-700 text-center">${data.totalTrees}</p>
          </div>
        </div>

        <h3 class="text-2xl font-bold mb-6">Field Photography</h3>
        <div class="grid grid-cols-2 gap-4">
          ${(data.media || []).map((m: any) => `
            <div class="aspect-video rounded-xl overflow-hidden border-2 border-gray-100 shadow-sm">
              <img src="${m.url}" class="w-full h-full object-cover" />
            </div>
          `).join('')}
        </div>
      </body>
    </html>
  `;
}

from neuron import h

class YuSimple(object):
	""" enter description here """
	def __init__(self):
		self.create_sections()
		self.build_topology()
		self.build_subsets()
		self.define_geometry()
		self.define_biophysics()
	#
	def create_sections(self):
		self.soma = h.Section(name='soma', cell=self)
		self.axon = h.Section(name='axon', cell=self)
	#
	def build_topology(self):
		self.axon.connect(self.soma(0))
	#
	def define_geometry(self):
		self.soma.L = 30
		self.soma.diam = 20
		self.soma.nseg = 5
		#
		self.axon.L = 50
		self.axon.diam = 1
		self.axon.nseg = 15
	#
	def define_biophysics(self):
		self.soma.Ra = 150#13500#150
		self.soma.insert('na')
		self.soma.gbar_na = 800
		self.soma.insert('kv')
		self.soma.gbar_kv = 320
		self.soma.cm = 0.75#13.27 #0.75
		#
		self.axon.Ra= 150#22500#150
		self.axon.insert('na')
		self.axon.gbar_na = 8000
		self.axon.insert('kv')
		self.axon.gbar_kv = 1500
		self.axon.cm = 0.5652#3.18#0.75
		#
		for sec in self.all:
			sec.ena = 60
			sec.ek = -90
			sec.insert('pas')
			sec.g_pas = 0.000033
			sec.e_pas = -70
	#
	def build_subsets(self):
		self.all = h.SectionList()
		self.all.wholetree(sec=self.soma)
